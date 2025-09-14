package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

func main() {
	// Kafka configuration
	broker := "localhost:9092"   // Replace with your broker address
	group := "my-consumer-group" // Replace with your consumer group
	topic := "my-topic"          // Replace with your topic

	// Create consumer
	c, err := kafka.NewConsumer(&kafka.ConfigMap{
		"bootstrap.servers":        broker,
		"group.id":                 group,
		"auto.offset.reset":        "earliest", // Start from earliest if no offset committed
		"enable.auto.commit":       true,
		"allow.auto.create.topics": true,
	})
	if err != nil {
		log.Fatalf("Failed to create consumer: %s", err)
	}
	defer c.Close()

	// Subscribe to topic
	err = c.SubscribeTopics([]string{topic}, nil)
	if err != nil {
		log.Fatalf("Failed to subscribe to topic: %s", err)
	}

	// Handle graceful shutdown
	sigchan := make(chan os.Signal, 1)
	signal.Notify(sigchan, syscall.SIGINT, syscall.SIGTERM)

	fmt.Println("Consumer started. Waiting for messages...")

	run := true
	for run {
		select {
		case sig := <-sigchan:
			fmt.Printf("Caught signal %v: terminating\n", sig)
			run = false
		default:
			ev := c.Poll(100) // Poll every 100ms
			if ev == nil {
				continue
			}

			switch e := ev.(type) {
			case *kafka.Message:
				fmt.Printf("Message on %s: %s\n", e.TopicPartition, string(e.Value))
			case kafka.Error:
				fmt.Fprintf(os.Stderr, "Error: %v\n", e)
				run = false
			default:
				// Other event types ignored for simplicity
			}
		}
	}

	fmt.Println("Closing consumer...")
}
