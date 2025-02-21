#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p /outputs

# Parse base64 input argument and decode to JSON
input_json=$(echo "$1" | base64 -d)

# Debug: Print decoded input
echo "Decoded input:" >&2
echo "$input_json" | jq '.' >&2

# Extract values from input JSON
messages=$(echo "$input_json" | jq -r '.messages')
temperature=$(echo "$input_json" | jq -r '.temperature')
max_tokens=$(echo "$input_json" | jq -r '.max_tokens')

# Start the ollama server in the background
nohup bash -c "ollama serve &" >&2

until curl -s http://127.0.0.1:11434 > /dev/null; do
    echo "Waiting for ollama to start..." >&2
    sleep 1
done

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

# Make the API call to Ollama's chat endpoint
response=$(curl -s -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d "$request")

# Debug: Print raw response and save it
echo "Raw response from Ollama:"
echo "$response" | jq '.'

# Save raw response to outputs
echo "$response" > "/outputs/raw_response.json"

exit 0 