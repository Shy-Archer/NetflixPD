package consumer;

import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.NoSuchElementException;

public class JdbcConsumer {
    public static void main(String[] args) {
        if (args.length != 3) {
            throw new NoSuchElementException("Oczekiwano 3 argumentów: <url> <user> <password>");
        }

        Connection connection = null;
        try {

            Class.forName("org.postgresql.Driver");

            connection = DriverManager.getConnection(args[0], args[1], args[2]);
            System.out.println("Connected to database");

            Statement statement = connection.createStatement();
            while (true) {

                ResultSet result = statement.executeQuery(
                        "SELECT * FROM movie_ratings ORDER BY window_start DESC LIMIT 50"
                );


                System.out.print("\u001b[2J");
                System.out.flush();

                System.out.println("================ NEW DATA ================");
                while (result.next()) {
                    // Zakładam, że kolumna window_start jest typu BIGINT (long UNIX timestamp)
                    long windowStartMillis = result.getLong("window_start");
                    Date sqlDate = new Date(windowStartMillis);
                    java.time.LocalDate windowStart = sqlDate.toLocalDate();

                    String movieId = result.getString("movie_id");
                    String title = result.getString("title");
                    int ratingCount = result.getInt("rating_count");
                    int ratingSum = result.getInt("rating_sum");
                    int uniqueRatingCount = result.getInt("unique_rating_count");

                    String dateFrom = String.format("%d-%02d-%02d",
                            windowStart.getYear(),
                            windowStart.getMonthValue(),
                            windowStart.getDayOfMonth()
                    );
                    java.time.LocalDate windowEnd = windowStart.plusDays(30);
                    String dateTo = String.format("%d-%02d-%02d",
                            windowEnd.getYear(),
                            windowEnd.getMonthValue(),
                            windowEnd.getDayOfMonth()
                    );

                    System.out.printf("%s - %s \t %s(%s) \t %d \t %d \t %d%n",
                            dateFrom, dateTo, title, movieId, ratingCount, ratingSum, uniqueRatingCount
                    );
                }

                Thread.sleep(10_000);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {

            if (connection != null) {
                try {
                    connection.close();
                } catch (Exception ignore) { }
            }
        }
    }
}
