source ./env.sh


# Wymagane biblioteki
KAFKA_PACKAGE="org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.0"
POSTGRES_PACKAGE="org.postgresql:postgresql:42.6.0"

$SPARK_HOME/bin/spark-submit \
  --packages "$KAFKA_PACKAGE","$POSTGRES_PACKAGE" \
  spark.py \
    "$INPUT_FILE_PATH" \
    "$KAFKA_BROKER" \
    "$KAFKA_TOPIC_DATA" \
    "$KAFKA_CONSUMER_GROUP" \
    "$POSTGRES_JDBC_URL" \
    "$POSTGRES_USER" \
    "$POSTGRES_PASSWORD" \
    "$ANOMALY_PERIOD_LENGTH" \
    "$ANOMALY_RATING_COUNT" \
    "$ANOMALY_RATING_MEAN" \
    "$KAFKA_TOPIC_ANOMALIES" \
    "$DELAY_TYPE"