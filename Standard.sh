source ./env.sh

# Ścieżka do JAR-a aplikacji (bez pakietu)
APP_JAR="out/artifacts/StandardOutput/StandardOutput.jar"




java -cp "$APP_JAR:/usr/lib/kafka/libs/*" StandardOutput \
     "$KAFKA_BROKER" \
     "$KAFKA_CONSUMER_GROUP" \
     "$KAFKA_TOPIC_ANOMALIES"
