source ./env.sh

# Ścieżka do JAR-a aplikacji (bez pakietu)
APP_JAR="out/artifacts/StandardOutput/StandardOutput.jar"



# Uruchomienie aplikacji — zakładamy brak pakietu (czyli klasa = StandardOutputConsumer)
java -cp "$APP_JAR:/usr/lib/kafka/libs/*" StandardOutput \
     "$KAFKA_BROKER" \
     "$KAFKA_CONSUMER_GROUP" \
     "$KAFKA_TOPIC_ANOMALIES"
