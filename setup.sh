source ./env.sh

mkdir "$INPUT_DIRECTORY_PATH"
echo "Input data directory created successfully."


echo "Copying input files from GCS..."
hadoop fs -copyToLocal gs://"${BUCKET_NAME}"/Netflix/netflix-prize-data/*.csv "$INPUT_DIRECTORY_PATH"
echo "Input files copied successfully."


kafka-topics.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVERS} --create --replication-factor 1 --partitions 1 --topic $KAFKA_ANOMALY_TOPIC_NAME
kafka-topics.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVERS} --create --replication-factor 1 --partitions 1 --topic $KAFKA_DATA_TOPIC_NAME
echo "Kafka topics created successfully."


docker run --name postgresdb -p 8432:5432 -e POSTGRES_PASSWORD=mysecretpassword -d postgres
# Opóźnienie przed wykonaniem skryptu SQL
echo "Waiting for PostgreSQL container to start..."
sleep 10
echo "PostgreSQL container started successfully."


echo "Executing SQL setup script..."
psql -h localhost -p 8432 -U postgres -v user="$JDBC_USERNAME" -v password="$JDBC_PASSWORD" -v db_name="$JDBC_DATABASE" -f setup.sql
echo "SQL setup script executed successfully."