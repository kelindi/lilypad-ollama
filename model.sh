#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p /outputs

# Parse input JSON argument
input_json="$1"

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

# Make the API call to Ollama's chat endpoint
response=$(curl -s -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d "$request")

# Get Unix timestamp for 'created' field
created=$(date +%s)

# Create JSON structure following OpenAI format
json_output="{
    \"id\": \"chatcmpl-$(openssl rand -hex 12)\",
    \"object\": \"chat.completion\",
    \"created\": $created,
    \"model\": \"$MODEL_ID\",
    \"choices\": [{
        \"index\": 0,
        \"message\": $(echo "$response" | jq '.message'),
        \"finish_reason\": \"stop\"
    }],
    \"usage\": {
        \"prompt_tokens\": null,
        \"completion_tokens\": null,
        \"total_tokens\": null
    }
}"

# Write JSON to file
echo "$json_output" > "/outputs/response.json"

# Print the response
echo "$json_output"

exit 0 