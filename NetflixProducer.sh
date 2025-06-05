  GNU nano 5.4                                                                            NetflixProducer.sh                                                                                      
#!/usr/bin/env bash
source ./env.sh

# Ścieżka do JAR-a aplikacji
APP_JAR="out/artifacts/NetflixProducer/NetflixProducer.jar"

# Ścieżka do bibliotek Kafka (thin-JAR, brak zależności w środku)
KAFKA_LIBS="/usr/lib/kafka/libs/*"

# Uruchomienie producenta
java -cp "$APP_JAR:$KAFKA_LIBS" NetflixProducer \
     "$INPUT_DIRECTORY_PATH" \
     "$KAFKA_PRODUCER_SLEEP_SEC" \
     "$KAFKA_TOPIC_DATA" \
     "$KAFKA_BROKER"