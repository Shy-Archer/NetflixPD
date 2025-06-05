package producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.NoSuchElementException;
import java.util.Properties;
import java.util.concurrent.TimeUnit;
import java.util.stream.Stream;

public class NetflixProducer {
    public static void main(String[] args) {
        if (args.length != 4) {
            throw new NoSuchElementException("Oczekiwano 4 argumentów: <directory> <sleepTimeSeconds> <topicName> <bootstrap.servers>");
        }

        String directory = args[0];
        String sleepTimeStr = args[1];
        String topicName = args[2];
        String bootstrapServers = args[3];

        Properties props = new Properties();
        props.put("bootstrap.servers", bootstrapServers);
        props.put("acks", "all");
        props.put("retries", "0");
        props.put("batch.size", "16384");
        props.put("linger.ms", "1");
        props.put("buffer.memory", "33554432");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        System.out.println("Starting producer");
        System.out.println("Directory: " + directory);
        System.out.println("Sleep time: " + sleepTimeStr);
        System.out.println("Topic name: " + topicName);
        System.out.println("Kafka server properties: " + props);

        KafkaProducer<String, String> producer = new KafkaProducer<>(props);


        File dir = new File(directory);
        String[] filePaths = dir.list();
        if (filePaths == null) {
            System.err.println("Folder jest pusty lub nie istnieje: " + directory);
            producer.close();
            return;
        }
        java.util.Arrays.sort(filePaths);

        System.out.println("Files to process: ");
        for (String f : filePaths) {
            System.out.print(directory + File.separator + f + ", ");
        }
        System.out.println();

        for (String filename : filePaths) {
            String path = directory + File.separator + filename;
            try {
                System.out.println("Processing file: " + path);
                // Odczytaj linia po linii, pomijając pierwszy wiersz (header)
                try (Stream<String> lines = Files.lines(Paths.get(path))) {
                    lines.skip(1).forEach(line -> {
                        String[] parts = line.split(",");
                        if (parts.length > 0) {
                            String key = parts[0];
                            // Wysłanie rekordu do Kafki
                            producer.send(new ProducerRecord<>(topicName, key, line));
                        }
                    });
                }
                // Poczekaj określoną liczbę sekund
                long sleepTimeSec = Long.parseLong(sleepTimeStr);
                TimeUnit.SECONDS.sleep(sleepTimeSec);
            } catch (IOException | InterruptedException e) {
                e.printStackTrace();
            }
        }

        System.out.println("Closing producer");
        producer.close();
    }
}
