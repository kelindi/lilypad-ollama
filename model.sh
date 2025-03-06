#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p /outputs

# Parse base64 input argument and decode to JSON
echo "Raw input (base64): $1" >&2
input_json=$(echo "$1" | base64 -d || echo "{}")

# Start the ollama server in the background
echo "Starting Ollama server..." >&2
nohup bash -c "ollama serve &" >&2

# Wait for server with timeout
timeout=30
start_time=$(date +%s)
while ! curl -s http://127.0.0.1:11434 > /dev/null; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))
    if [ $elapsed -gt $timeout ]; then
        echo "Timeout waiting for Ollama server" >&2
        exit 1
    fi
    echo "Waiting for ollama to start... ($elapsed seconds)" >&2
    sleep 1
done

echo "Ollama server started" >&2

# Use the OpenAI-compatible endpoint
endpoint="/v1/chat/completions"

# Pass through the input JSON, only setting essential defaults
request=$(echo "$input_json" | jq '
  # Set essential defaults if missing
  . + {
    model: (.model // "'$MODEL_ID'"),
    messages: (.messages // [{"role":"user","content":"What is bitcoin?"}]),
    stream: false
  }
')

# Log the request for debugging
echo "Using OpenAI-compatible endpoint: $endpoint" >&2
echo "Request: $request" >&2

# Make the API call to Ollama using the OpenAI-compatible endpoint
echo "Making request to Ollama..." >&2
response=$(curl -s "http://127.0.0.1:11434$endpoint" \
  -H "Content-Type: application/json" \
  -d "$request")

# Save debug info
{
  echo "=== Debug Info ===" 
  echo "Input (base64): $1"
  echo "Decoded input: $input_json"
  echo "Endpoint used: $endpoint"
  echo "Request: $request"
  echo "Response: "
  echo "$response"
  echo "=== Server Status ==="
  echo "Ollama version: $(ollama --version)"
  echo "Model list: $(ollama list)"
} > "/outputs/debug.log"

# Save and output the response
echo "$response" > "/outputs/response.json"
echo "$response"

exit 0 