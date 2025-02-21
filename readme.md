# Lilypad Ollama Model Template

This is a template for creating Lilypad modules for Ollama models.

## Usage

To create a new model module:

```bash
./stack build <model_name> <version>
```

Example:
```bash
./stack build llama2 7b
```

## Available Commands

- `./stack build <model_name> <version>` - Build a new model image
- `./stack run <image_name> <json_input>` - Run the model locally
- `./stack configure <dockerhub-username>` - Configure Docker Hub username for pushing images
- `./stack push <image_name> [tag]` - Push image to Docker Hub with optional tag defaults to latest. Push also creates a lilypad module file in the current directory.
- `./stack list` - Show available Ollama models and their versions

## Directory Structure

```
.
├── Dockerfile              # Template Dockerfile for all models
├── model.sh               # Core model execution script
├── lilypad_module.json.tmpl # Lilypad module template
├── stack                  # Main command runner
└── stack/commands/        # Individual command implementations
    ├── build
    ├── configure
    ├── images
    ├── list
    ├── push
    └── run
```

## Creating a New Model

1. Choose your model from available Ollama models (run `./stack list` to see options):

   Available model categories:
   - Large Models (>100B) - deepseek-v3, llama3.1, deepseek-coder-v2, etc.
   - Mixture of Experts Models - mixtral, dolphin-mixtral, wizardlm2
   - Mid-Size Models (30-100B) - llama2/3, codellama, qwen/2, etc.
   - Standard Models (7-30B) - llama2, mistral, codellama, phi4, etc.
   - Small Models (<7B) - phi, orca-mini, tinyllama, qwen, etc.
   - Vision Models - llava, bakllava, moondream, etc.
   - Code-Specific Models - codellama, deepseek-coder, starcoder2, etc.
   - Embedding Models - nomic-embed-text, bge-m3, etc.

2. Run the build command with your chosen model and version:
   ```bash
   ./stack build <model_name> <version>
   ```
   Example: `./stack build llama2 7b`

3. Test the model locally:
   ```bash
   ./stack run lilypad-ollama-<model_name>-<version>:latest '{"messages": [{"role": "user", "content": "Hello!"}]}'
   ```
   Example: `./stack run lilypad-ollama-llama2-7b:latest '{"messages": [{"role": "user", "content": "Hello!"}]}'`

4. Configure Docker Hub and push the image:
   ```bash
   # First configure your Docker Hub username
   ./stack configure <dockerhub-username>
   
   # Then push the image
   ./stack push lilypad-ollama-<model_name>-<version>:latest [optional-tag]
   ```
   Example: `./stack push lilypad-ollama-llama2-7b:latest v1.0.0`

