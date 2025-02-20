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
- `./stack push <image_name> <dockerhub_username>` - Push image to Docker Hub
- `./stack generate-readme <model_name> <version>` - Generate model-specific README

## Directory Structure

```
.
├── Dockerfile              # Template Dockerfile for all models
├── model.sh               # Core model execution script
├── lilypad_module.json.tmpl # Lilypad module template
├── stack                  # Main command runner
└── stack/commands/        # Individual command implementations
    ├── build
    ├── generate-readme
    ├── push
    └── run
```

## Creating a New Model

1. Choose your model from available Ollama models
2. Run the build command:
   ```bash
   ./stack build <model_name> <version>
   ```
3. Test locally:
   ```bash
   ./stack run lilypad-ollama-<model_name>:latest '{"messages": [{"role": "user", "content": "Hello!"}]}'
   ```
4. Push to Docker Hub:
   ```bash
   ./stack push lilypad-ollama-<model_name>:latest <your-username>
   ```

## License

[License details here]
