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

# Set default values only if they don't exist in the input
# This preserves all original parameters while ensuring required ones exist
request=$(echo "$input_json" | jq '
  # Set defaults only if fields are missing
  . + {
    model: (.model // "'$MODEL_ID'"),
    messages: (.messages // [{"role":"user","content":"What is bitcoin?"}]),
    temperature: (.temperature // 0.7),
    max_tokens: (.max_tokens // 2048),
    stream: false
  }
')

# Make the API call to Ollama's chat endpoint
echo "Making request to Ollama..." >&2
response=$(curl -s http://127.0.0.1:11434/api/chat/completions \
  -H "Content-Type: application/json" \
  -d "$request")

# Save debug info
{
  echo "=== Debug Info ===" 
  echo "Input (base64): $1"
  echo "Decoded input: $input_json"
  echo "Request to Ollama: $request"
  echo "Response from Ollama: "
  echo "$response"
  echo "=== Server Status ==="
  echo "Ollama version: $(ollama --version)"
  echo "Model list: $(ollama list)"
  echo "Server health check: $(curl -s http://127.0.0.1:11434)"
} > "/outputs/debug.log"

# Save and output the raw Ollama response
echo "$response" > "/outputs/response.json"
echo "$response"

exit 0 