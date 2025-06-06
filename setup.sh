source ./env.sh
mkdir "$INPUT_DIRECTORY_PATH"
echo "Input data directory created successfully."

# Pobieranie plików z GCS
echo "Copying input files from GCS..."
hadoop fs -copyToLocal gs://"${BUCKET_NAME}"/Netflix/netflix-prize-data/*.csv "$INPUT_DIRECTORY_PATH"
echo "Input files copied successfully."


# Tworzenie tematów Kafka
echo "Creating Kafka topics..."
declare -a topics=($KAFKA_TOPIC_DATA $KAFKA_TOPIC_ANOMALIES)

for i in "${topics[@]}"
do
  existing_topic_check=$( /usr/lib/kafka/bin/kafka-topics.sh --bootstrap-server ${CLUSTER_NAME}-w-0:9092 --list| grep "$i")
  if [ -n "$existing_topic_check" ]; then
      # Delete the existing topic
      /usr/lib/kafka/bin/kafka-topics.sh --bootstrap-server ${CLUSTER_NAME}-w-0:9092 --delete --topic "$i"
      echo "Deleted existing topic: $i"
  else
      echo "Topic '$i' does not exist."
  fi

  # Create a new topic
  /usr/lib/kafka/bin/kafka-topics.sh --bootstrap-server ${CLUSTER_NAME}-w-0:9092 --create --topic "$i" --partitions 1 --replication-factor 1
  echo "Created new topic: $i"
done
wget https://jdbc.postgresql.org/download/postgresql-42.6.0.jar
echo "Currently existing topics: "
/usr/lib/kafka/bin/kafka-topics.sh --bootstrap-server ${CLUSTER_NAME}-w-0:9092 --list

# Uruchomienie kontenera Docker z bazą danych PostgreSQL
echo "Starting PostgreSQL container..."
docker run --name postgresdb -p 8432:5432 -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -d postgres
# Opóźnienie przed wykonaniem skryptu 
echo "Waiting for PostgreSQL container to start..."
sleep 10
echo "PostgreSQL container started successfully."
# Wykonanie skryptu SQL
echo "Executing SQL setup script..."
PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p 8432 -U postgres -v user="$POSTGRES_USER" -v password="$POSTGRES_PASSWORD" -v name="$POSTGRES_DB_NAME" -f setup.sql
echo "SQL setup script executed successfully."