source ./env.sh

# Ścieżka do JAR-a aplikacji (bez spacji!)
APP_JAR="out/artifacts/JbdcConsumer/JdbcConsumer.jar"

# Ścieżka do sterownika PostgreSQL (upewnij się, że plik istnieje w tym katalogu)
PG_JAR="postgresql-42.6.0.jar"

# Uruchomienie programu
java -cp "$APP_JAR:$PG_JAR" JDBCConsumer \
     "$POSTGRES_JDBC_URL" "$POSTGRES_USER" "$POSTGRES_PASSWORD"