#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p /outputs

# Parse base64 input argument and decode to JSON
echo "Raw input (base64): $1" >&2
input_json=$(echo "$1" | base64 -d || echo "{}")

# Debug: Print decoded input
echo "Decoded input:" >&2
echo "$input_json" | jq '.' || echo "Failed to parse decoded input as JSON" >&2

# Extract values from input JSON with defaults
messages=$(echo "$input_json" | jq -r '.messages // empty' || echo '[{"role":"user","content":"What is bitcoin?"}]')
temperature=$(echo "$input_json" | jq -r '.temperature // empty' || echo "0.7")
max_tokens=$(echo "$input_json" | jq -r '.max_tokens // empty' || echo "2048")

echo "Extracted values:" >&2
echo "messages: $messages" >&2
echo "temperature: $temperature" >&2
echo "max_tokens: $max_tokens" >&2

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

# Check if model is pulled
echo "Checking model status..." >&2
if ! ollama list | grep -q "$MODEL_ID"; then
    echo "Model $MODEL_ID not found, pulling..." >&2
    ollama pull "$MODEL_ID"
fi

# Prepare the chat completion request
request=$(cat <<EOF
{
  "model": "$MODEL_ID",
  "messages": $messages,
  "temperature": $temperature,
  "max_tokens": $max_tokens,
  "stream": false
}
EOF
)

# Debug: Print the request
echo "Sending request to Ollama:" >&2
echo "$request" | jq '.' || echo "Failed to parse request as JSON" >&2

# Make the API call to Ollama's chat endpoint with more debugging
echo "Making request to Ollama..." >&2
response=$(curl -v -X POST http://127.0.0.1:11434/api/chat \
  -H "Content-Type: application/json" \
  -d "$request" 2>&1)

# Debug: Print raw response
echo "Raw response from Ollama:" >&2
echo "$response"

# Save debug info
{
  echo "=== Debug Info ===" 
  echo "Input (base64): $1"
  echo "Decoded input: $input_json"
  echo "Request to Ollama: $request"
  echo "Response from Ollama: $response"
  echo "=== Server Status ==="
  echo "Ollama version: $(ollama --version)"
  echo "Model list: $(ollama list)"
  echo "Server health check: $(curl -s http://127.0.0.1:11434)"
  echo "=== Network Status ==="
  echo "Hosts file:"
  cat /etc/hosts
  echo "Network interfaces:"
  ip addr
} > "/outputs/debug.log"

# Save raw response to outputs
echo "$response" > "/outputs/raw_response.json"

echo "Files in /outputs:" >&2
ls -l /outputs >&2

exit 0 