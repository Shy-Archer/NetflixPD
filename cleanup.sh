docker stop postgresdb
docker rm postgresdb

kafka-topics.sh --bootstrap-server ${CLUSTER_NAME}-w-1:9092 --delete --topic $KAFKA_TOPIC_ANOMALIES
kafka-topics.sh --bootstrap-server ${CLUSTER_NAME}-w-1:9092 --delete --topic $KAFKA_TOPIC_DATA

rm -fr ./*