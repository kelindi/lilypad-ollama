#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p /outputs

# Parse base64 input argument and decode to JSON
echo "Raw input (base64): $1" >&2
input_json=$(echo "$1" | base64 -d)

# Debug: Print decoded input
echo "Decoded input:" >&2
echo "$input_json" | jq '.' >&2

# Extract values from input JSON
messages=$(echo "$input_json" | jq -r '.messages')
temperature=$(echo "$input_json" | jq -r '.temperature')
max_tokens=$(echo "$input_json" | jq -r '.max_tokens')

echo "Extracted values:" >&2
echo "messages: $messages" >&2
echo "temperature: $temperature" >&2
echo "max_tokens: $max_tokens" >&2

# Start the ollama server in the background
nohup bash -c "ollama serve &" >&2

until curl -s http://127.0.0.1:11434 > /dev/null; do
    echo "Waiting for ollama to start..." >&2
    sleep 1
done

echo "Ollama server started" >&2

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
echo "$request" | jq '.' >&2

# Make the API call to Ollama's chat endpoint and capture both stdout and stderr
response=$(curl -v -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d "$request" 2>&1)

# Debug: Print raw response and curl output
echo "Complete curl output:" >&2
echo "$response" >&2

# Try to extract just the response body
response_body=$(echo "$response" | grep -v "^*" | grep -v "^>" | grep -v "^<" | grep -v "^}" | grep -v "^{" | tr -d '\n')
echo "Extracted response body:" >&2
echo "$response_body" | jq '.' >&2

# Save debug info
{
  echo "=== Debug Info ===" 
  echo "Input (base64): $1"
  echo "Decoded input: $input_json"
  echo "Request: $request"
  echo "Raw response: $response"
  echo "Response body: $response_body"
} > "/outputs/debug.log"

# Save raw response to outputs
echo "$response" > "/outputs/raw_response.json"

echo "Files in /outputs:" >&2
ls -l /outputs >&2

exit 0 