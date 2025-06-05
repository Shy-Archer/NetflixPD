from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col, split, window, to_timestamp, unix_timestamp, count, sum, approx_count_distinct,
    avg, concat, lit, concat_ws, to_json, struct
)
from pyspark.sql.types import StructType, StringType, IntegerType
import sys
import socket


def save_to_jdbc(batch_df, jdbc_url, jdbc_props, mode="append"):
    
    batch_df.write.mode(mode).jdbc(jdbc_url, "movie_ratings", properties=jdbc_props)


def real_time_processing(ratings_df, movies_df, jdbc_url, jdbc_user, jdbc_password, delay_mode):
   

    if delay_mode == "A":
        watermark_delay = "1 day"
        output_mode = "update"
    elif delay_mode == "C":
        watermark_delay = "30 days"        
        output_mode = "append"             
    else:
        raise ValueError("delay_mode must be 'A' or 'C'")

    # Agregacja miesięczna
    monthly_df = (
        ratings_df.withWatermark("ts", watermark_delay)
        .groupBy(window(col("ts"), "1 month"), col("movie_id"))
        .agg(
            count("*").alias("rating_count"),
            sum("rating").alias("rating_sum"),
            approx_count_distinct("user_id").alias("unique_rating_count")
        )
        .join(movies_df, col("movie_id") == movies_df["_c0"], "inner")
        .select(
            unix_timestamp(col("window.start")).alias("window_start"),
            col("movie_id"),
            movies_df["_c2"].alias("title"),
            "rating_count",
            "rating_sum",
            "unique_rating_count",
        )
    )

    jdbc_props = {
        "user": jdbc_user,
        "password": jdbc_password,
        "driver": "org.postgresql.Driver",
    }

    return (
        monthly_df.writeStream
        .outputMode(output_mode)
        .foreachBatch(lambda df, _id: save_to_jdbc(df, jdbc_url, jdbc_props))
        .option("checkpointLocation", "/tmp/checkpoints/etl")
        .trigger(processingTime="20 seconds")
        .start()
    )


def anomalies(ratings_df, movies_df, window_days, min_cnt, min_avg, kafka_bootstrap, kafka_topic):
    anomalies_df = (
        ratings_df.withWatermark("ts", "1 day")
        .groupBy(window(col("ts"), f"{window_days} days", "1 day"), col("movie_id"))
        .agg(
            count("*").alias("rating_count"),
            avg("rating").alias("avg_rating"),
        )
        .filter((col("rating_count") >= min_cnt) & (col("avg_rating") >= min_avg))
        .join(movies_df, col("movie_id") == movies_df["_c0"], "inner")
        .select(
            col("window.start").alias("period_start"),
            col("window.end").alias("period_end"),
            movies_df["_c2"].alias("title"),
            "movie_id",
            "rating_count",
            "avg_rating",
        )
    )

  
    return (
        anomalies_df.select(to_json(struct(*anomalies_df.columns)).alias("value"))
        .writeStream
        .format("kafka")
        .option("kafka.bootstrap.servers", kafka_bootstrap)
        .option("topic", kafka_topic)
        .option("checkpointLocation", "/tmp/checkpoints/anomalies")
        .outputMode("append")
        .start()
    )



if __name__ == "__main__":
    if len(sys.argv) != 13:
        sys.exit(
            "Usage: script.py <input_file_path> <kafka_bootstrap_servers> <kafka_topic> <group_id> "
            "<jdbc_url> <jdbc_user> <jdbc_password> <sliding_window_size_days> "
            "<anomaly_rating_count_threshold> <anomaly_rating_mean_threshold> "
            "<kafka_anomaly_topic> <delay_mode>"
        )

    (
        input_file_path,
        kafka_bootstrap_servers,
        kafka_topic,
        group_id,
        jdbc_url,
        jdbc_user,
        jdbc_password,
        sliding_window_size_days,
        anomaly_rating_count_threshold,
        anomaly_rating_mean_threshold,
        kafka_anomaly_topic,
        delay_mode,
    ) = sys.argv[1:13]

    spark = SparkSession.builder.appName("NetflixPrizeStreaming").getOrCreate()
    spark.sparkContext.setLogLevel("WARN")

    
    host_name = socket.gethostname()
    raw_kafka_df = (
        spark.readStream.format("kafka")
        .option("kafka.bootstrap.servers", kafka_bootstrap_servers)
        .option("subscribe", kafka_topic)
        .option("group.id", group_id)
        .option("startingOffsets", "latest")
        .option("failOnDataLoss", "false")
        .load()
    )


    raw_values = raw_kafka_df.selectExpr("CAST(value AS STRING) AS csv")
    parts = split(col("csv"), ",")

    ratings_df = (
        raw_values
        .withColumn("ts", to_timestamp(parts[0], "yyyy-MM-dd"))
        .withColumn("movie_id", parts[1].cast(IntegerType()))
        .withColumn("user_id", parts[2].cast(StringType()))
        .withColumn("rating", parts[3].cast(IntegerType()))
        .drop("csv")
    )


    movies_df = (
        spark.read.option("header", False).csv(input_file_path)
    )

    streams = []

   
    streams.append(
        real_time_processing(
            ratings_df,
            movies_df,
            jdbc_url,
            jdbc_user,
            jdbc_password,
            delay_mode.upper(),
        )
    )


    streams.append(
        anomalies(
            ratings_df,
            movies_df,
            int(sliding_window_size_days),
            int(anomaly_rating_count_threshold),
            float(anomaly_rating_mean_threshold),
            kafka_bootstrap_servers,
            kafka_anomaly_topic,
         )
    )

    for q in streams:
        q.awaitTermination()
