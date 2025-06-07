export BUCKET_NAME="bigdata-24-lw"
export CLUSTER_NAME=$(/usr/share/google/get_metadata_value attributes/dataproc-cluster-name)
export HADOOP_CONF_DIR=/etc/hadoop/conf
export HADOOP_CLASSPATH=`hadoop classpath`
export INPUT_DIRECTORY_PATH="$HOME/netflix-prize-data"
export INPUT_FILE_PATH="gs://${BUCKET_NAME}/Netflix/movie_titles.csv"

export KAFKA_PRODUCER_SLEEP_SEC=30
export KAFKA_TOPIC_DATA="netflix-ratings"
export KAFKA_TOPIC_ANOMALIES="netflix-ratings-anomalies"
export KAFKA_BROKER="${CLUSTER_NAME}-w-0:9092"
export KAFKA_CONSUMER_GROUP="netflix-ratings-group"



export POSTGRES_JDBC_URL="jdbc:postgresql://localhost:8432/netflix_ratings"
export POSTGRES_USER="postgres"
export POSTGRES_PASSWORD="mysecretpassword"
export POSTGRES_DB_NAME="netflix_ratings"


export ANOMALY_PERIOD_LENGTH=1
export ANOMALY_RATING_COUNT=2
export ANOMALY_RATING_MEAN=2
export DELAY_TYPE="C"