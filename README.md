# Python Development Environment

This repository contains setup utility scripts to initialise Nix-based development environments for Python development with both standard and ML/scientific workflows.

## Features

### Python Development

#### Dependency management

- **Standard Python**: Development environment with uv for package management
- **ML/Scientific Python**: Development environment with pixi for projects requiring complex system dependencies

#### Project Initialization

- `create-uv-project.sh <project-name>`: Create standard Python projects with uv
- `create-pixi-project.sh <project-name>`: Create ML/scientific projects with pixi

#### VS Code Integration

- `update_vscode_settings.sh`
  - Automatic configuration of Python interpreter
  - Safe updating of settings (preserves manual changes)
  - Recommended settings for Python development

#### Code Quality Tools

- `lefthook` for Git hooks
- `ruff` for linting and formatting

## Getting Started

### Prerequisites

Use either of the following approaches. If using `nix`, the `flake` will install the necessary dependencies.

#### `nix` & flakes
- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/docs/installation.html)

#### No `nix`
- [jq](https://jqlang.org/)
- [uv](https://docs.astral.sh/uv/)
- [pixi](https://pixi.sh/dev/)

### Creating Projects

#### Standard Python Project

```bash
# Create a new project with Python 3.11
create-uv-project.sh my-project
cd my-project

# Install dependencies
uv pip install -e .
```

#### ML/Scientific Project

```bash
# Create a new ML project with Python 3.11
create-pixi-project.sh ml-project
cd ml-project

# Add dependencies
pixi add numpy pandas scikit-learn
pixi shell
```

## Project Structure

A typical project structure created by the initialization scripts:

```
project-name/
├── .venv-py3.11/       # Python virtual environment
├── .vscode/            # VS Code configuration
│   └── settings.json
├── src/                # Source code
│   └── __init__.py
├── tests/              # Tests
│   └── __init__.py
└── lefthook.yml        # Git hooks configuration
```

For pixi projects, you'll also have:

```
project-name/
├── .pixi/              # pixi environment
├── pixi.toml           # pixi configuration
└── pixi.lock           # Locked dependencies
```

## Common Tasks

### Installing Dependencies

For uv projects:
```bash
uv pip install -e .
uv pip install -r requirements.txt
```

For pixi projects:
```bash
pixi add numpy pandas scikit-learn
pixi shell
```

### Running Tests

For uv projects:
```bash
pytest
```

For pixi projects:
```bash
pixi run test
```

### Linting and Formatting

For uv projects:
```bash
ruff check .
ruff format .
```

For pixi projects:
```bash
pixi run lint
pixi run format
```

## Basic CI/CD Integration

For CI/CD environments without Nix:

### Standard Python Projects

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    - name: Install uv
      run: pip install uv
    - name: Install dependencies
      run: |
        uv venv .venv
        source .venv/bin/activate
        uv pip install -e ".[dev]"
    - name: Run tests
      run: |
        source .venv/bin/activate
        pytest
```

### ML Projects

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Install pixi
      run: |
        curl -fsSL https://pixi.sh/install.sh | bash
        echo "$HOME/.pixi/bin" >> $GITHUB_PATH
    - name: Set up environment
      run: |
        pixi install
    - name: Run tests
      run: |
        pixi run test
```

## License

[MIT](LICENSE)
