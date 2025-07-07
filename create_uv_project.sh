#!/bin/bash
# create_uv_project.sh - Create a new Python project with uv

# Display usage information
usage() {
  echo "Usage: $0 <project-name>"
  echo ""
  echo "Arguments:"
  echo "  project-name - Name of the project (and directory)"
  exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
  usage
fi

project_name=$1

# Check if project directory already exists
if [ -d "$project_name" ]; then
  echo "Error: Directory '$project_name' already exists"
  exit 1
fi

# Create project directory
mkdir -p "$project_name"

# Copy nix flake
cp ~/projects/python_setup_utils/flakeTemplate.nix "$project_name/flake.nix"

# Setup project directory
cd "$project_name" || exit 1

# Create project-specific .envrc
echo 'use flake .#uvShell' > .envrc

# Create README.md
cat > README.md << EOF
# $project_name

Python project description goes here.

## Setup

This project uses uv for dependency management.

### Development Setup

1. If using Nix and direnv, enter directory, allow direnv (\`direnv allow\`) and ensure \`flake.nix\` is being tracked in \`git\`
2. If relying on system to provide build tools, ensure you have \`uv\`, \`lefthook\`, \`gcc\` and \`gnumake\` installed
3. Create a virtual environment: \`uv venv\`
4. Activate the environment: \`source .venv/bin/activate\`
5. Initialize uv: \`uv init\`
6. Install dependencies: \`uv pip install -e .\`
7. Update IDE settings, e.g: run \`~/projects/python_setup_utils/update_vscode_settings.sh\` for VS Code

### Running Tests

\`\`\`bash
pytest
\`\`\`

### Code Formatting

\`\`\`bash
ruff format .
\`\`\`

### Linting

\`\`\`bash
ruff check .
\`\`\`
EOF

# Initialize lefthook
lefthook install

# Create lefthook.yml
cat > lefthook.yml << EOF
pre-commit:
  parallel: true
  commands:
    ruff:
      glob: "*.py"
      run: ruff check {staged_files} && ruff format {staged_files}
    pytest:
      glob: "*.py"
      run: pytest
EOF

# Create VS Code settings directory
mkdir -p .vscode

echo "Python project with uv created successfully: $project_name"
echo ""
echo "Next steps:"
echo "1. cd $project_name"
echo "2. If using nix: direnv allow"
echo "3. Create a virtual environment: uv venv"
echo "4. Activate the environment: source .venv/bin/activate"
echo "5. Initialize uv: uv init"
echo "6. Update VS Code settings: update_vscode_settings.sh"
