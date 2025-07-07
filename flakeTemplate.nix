{
  description = "Development environment with uv and pixi shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Common system dependencies
        systemDeps = [
          pkgs.gcc
          pkgs.gnumake
        ];
      in
      {
        devShells = {
          # Default shell with minimal tools
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.jq
              pkgs.lefthook
            ];
            
            shellHook = ''
              # Add setup_utils to PATH
              export PATH=$PATH:${self}/setup_utils
              
              echo "Development Environment Setup Tools"
              echo ""
              echo "Available commands:"
              echo "- create_uv_project.sh <project-name>"
              echo "- create_pixi_project.sh <project-name>"
              echo "- update_vscode_settings.sh"
              echo ""
              echo "Use 'cd <project-dir>' and 'direnv allow' to activate project environment"
            '';
          };
          
          # Shell with uv
          uvShell = pkgs.mkShell {
            buildInputs = [
              # Package manager
              pkgs.uv
              
              # Development tools
              pkgs.jq
              pkgs.lefthook
              
              # System dependencies
              systemDeps
            ];
            
            shellHook = ''
              echo "Python Development Environment with uv"
              echo ""
              echo "Tools available:"
              echo "- uv: $(uv --version)"
              echo "- lefthook: $(lefthook version)"
              echo ""
              
              # Add setup_utils to PATH
              export PATH=$PATH:${self}/setup_utils
              
              # Set environment variables for libraries
              export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath systemDeps}:$LD_LIBRARY_PATH
              
              # Activate virtual environment if it exists
              if [ -d ".venv" ]; then
                source .venv/bin/activate
                echo "Activated virtual environment: .venv"
              fi
            '';
          };
          
          # Shell with pixi
          pixiShell = pkgs.mkShell {
            buildInputs = [
              # Package manager
              pkgs.pixi
              
              # Development tools
              pkgs.jq
              pkgs.lefthook
              
              # System dependencies
              systemDeps
            ];
            
            shellHook = ''
              echo "Python Development Environment with pixi"
              echo ""
              echo "Tools available:"
              echo "- pixi: $(pixi --version)"
              echo "- lefthook: $(lefthook version)"
              echo ""
              
              # Add setup_utils to PATH
              export PATH=$PATH:${self}/setup_utils
              
              # Set environment variables for libraries
              export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath systemDeps}:$LD_LIBRARY_PATH
              
              # Check for pixi environment
              if [ -f "pixi.toml" ]; then
                echo "pixi environment detected. Use 'pixi shell' to activate."
              fi
            '';
          };
        };
      }
    );
}