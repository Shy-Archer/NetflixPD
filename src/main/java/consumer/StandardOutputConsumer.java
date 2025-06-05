package consumer;

import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;

import java.time.Duration;
import java.util.Collections;
import java.util.NoSuchElementException;
import java.util.Properties;

public class StandardOutputConsumer {
    public static void main(String[] args) {
        if (args.length != 3) {
            throw new NoSuchElementException("Oczekiwano 3 argumentów: <bootstrap.servers> <group.id> <topic>");
        }

        String bootstrapServers = args[0];
        String groupId = args[1];
        String topic = args[2];

        Properties props = new Properties();
        props.put("bootstrap.servers", bootstrapServers);
        props.put("group.id", groupId);
        props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

        System.out.println(props);
        System.out.println("Starting consumer");

        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
        System.out.println("Subscribing to: " + topic);
        consumer.subscribe(Collections.singletonList(topic));

        try {
            while (true) {
                // Polluj z timeoutem 6000 sekund (czyli 100 minut)
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofSeconds(6000));
                for (ConsumerRecord<String, String> record : records) {
                    System.out.println(record.value());
                }
            }
        } finally {
            consumer.close();
        }
    }
}
