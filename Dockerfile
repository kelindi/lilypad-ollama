# Use the existing ollama Dockerfile as the base
FROM ollama/ollama

# Build argument for model name and version
ARG MODEL_NAME=deepseek-r1
ARG MODEL_VERSION=1.5b
ENV MODEL_ID="${MODEL_NAME}:${MODEL_VERSION}"

# Set the working directory
WORKDIR /app

# Update and install necessary packages
RUN apt-get update && apt-get install -y wget curl jq

# Run ollama in the background and pull the specified model
RUN nohup bash -c "ollama serve &" && \
    until curl -s http://127.0.0.1:11434 > /dev/null; do \
        echo "Waiting for ollama to start..."; \
        sleep 5; \
    done && \
    echo "Pulling model: $MODEL_ID" && \
    ollama pull $MODEL_ID

EXPOSE 11434

# Set the environment variable for the ollama host
ENV OLLAMA_HOST=0.0.0.0

# Create outputs directory and set permissions
RUN mkdir -p /outputs && chmod 777 /outputs

# Set outputs directory as a volume
VOLUME /app/outputs

# Copy a script to start ollama and handle input
COPY run_model.sh /app/run_model.sh
RUN chmod +x /app/run_model.sh

# Set the entrypoint to the script
ENTRYPOINT ["/app/run_model.sh"]