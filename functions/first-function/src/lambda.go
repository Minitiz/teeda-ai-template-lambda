package main

import (
	"context"
	"encoding/json"
	"log"
	"os"
	"test/pkg/logic"

	"github.com/aws/aws-lambda-go/lambda"
)

var Logic logic.LogicInterface

func init() {
	Logic = logic.New()
}

type Request struct {
	ID string `json:"id"`
}

func handleRequest(ctx context.Context, event json.RawMessage) error {
	// Parse the input event
	var req Request
	if err := json.Unmarshal(event, &req); err != nil {
		log.Printf("Failed to unmarshal event: %v", err)
		return err
	}
	testEnv := os.Getenv("TEST_ENV")
	Logic.Do()
	// Access environment variables
	log.Printf("request received OK: %s | env: %s", req.ID, testEnv)
	return nil
}

func main() {
	lambda.Start(handleRequest)
}
