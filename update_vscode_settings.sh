#!/bin/bash
# update_vscode_settings.sh - Update VS Code settings for Python interpreter
# Auto-detects whether the project uses uv or pixi

settings_file=".vscode/settings.json"

# Create .vscode directory if it doesn't exist
mkdir -p .vscode

# Create settings file with default values if it doesn't exist
if [ ! -f "$settings_file" ]; then
  echo '{}' > "$settings_file"
fi

# Detect project type and get interpreter path
if [ -f "pixi.toml" ]; then
  # This is a pixi project
  echo "Detected pixi project"
  
  # Check if pixi environment exists
  if [ -d ".pixi/env" ]; then
    interpreter_path=".pixi/env/bin/python"
    echo "Found pixi interpreter: $interpreter_path"
  else
    echo "Warning: pixi environment not found. Run 'pixi init' first."
    exit 1
  fi
elif [ -d ".venv" ]; then
  # This is a uv project
  echo "Detected uv project"
  interpreter_path=".venv/bin/python"
  echo "Found uv interpreter: $interpreter_path"
else
  echo "No Python environment detected. Create a virtual environment first."
  echo "For uv: uv venv"
  echo "For pixi: pixi init"
  exit 1
fi

# Update python.defaultInterpreterPath while preserving other settings
if command -v jq &> /dev/null; then
  # Use jq to update the settings file
  jq --arg path "$PWD/$interpreter_path" '.["python.defaultInterpreterPath"] = $path' "$settings_file" > "$settings_file.tmp"
  mv "$settings_file.tmp" "$settings_file"
  
  # Add recommended settings if they don't exist
  jq '.["python.analysis.extraPaths"] = ["${workspaceFolder}/src"] | 
      .["python.formatting.provider"] = "none" | 
      .["editor.defaultFormatter"] = "charliermarsh.ruff" | 
      .["python.linting.enabled"] = true | 
      .["python.linting.ruffEnabled"] = true | 
      .["editor.formatOnSave"] = true' "$settings_file" > "$settings_file.tmp"
  mv "$settings_file.tmp" "$settings_file"
  
  echo "Updated VS Code settings: python.defaultInterpreterPath = $PWD/$interpreter_path"
else
  echo "Warning: jq not found. VS Code settings not updated."
fi