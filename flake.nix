# NixCats Neovim Configuration
# Based on tempnvim template with direnv support
{
  description = "NichNvim - Neovim with nixCats";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    # Latest Neovim
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plugins not in nixpkgs
    "plugins-render-markdown" = {
      url = "github:MeanderingProgrammer/render-markdown.nvim";
      flake = false;
    };
    "plugins-img-clip" = {
      url = "github:HakonHarnes/img-clip.nvim";
      flake = false;
    };
    "plugins-multicursor" = {
      url = "github:jake-stewart/multicursor.nvim";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixCats,
      neovim-nightly-overlay,
      ...
    }@inputs:
    let
      inherit (nixCats) utils;
      luaPath = ./nvim;
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;

      extra_pkg_config = {
        allowUnfree = true;
      };

      dependencyOverlays = [
        (utils.standardPluginOverlay inputs)
        neovim-nightly-overlay.overlays.default
      ];

      categoryDefinitions =
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }@packageDef:
        {
          # LSP servers and runtime dependencies
          # These are added to PATH - direnv can override them with suffix-path = true
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              # LSP servers
              lua-language-server
              basedpyright
              ruff
              python312Packages.python-lsp-server
              clang-tools # clangd
              marksman
              texlab
              tinymist
              nil # nix lsp
              nodePackages.vscode-json-languageserver
              yaml-language-server
              taplo # toml

              # Formatters
              stylua
              prettierd
              shfmt
              yapf
              isort
              typstyle
              nodePackages.prettier

              # Tools
              ripgrep
              fd
              lazygit
              git

              # DAP
              python312Packages.debugpy
              lldb # for C/C++
            ];
          };

          # Plugins loaded at startup
          startupPlugins = {
            gitPlugins = with pkgs.neovimPlugins; [
              render-markdown
              img-clip
              multicursor
            ];

            general = with pkgs.vimPlugins; [
              # Core
              lazy-nvim
              plenary-nvim
              nvim-web-devicons

              # Completion (use nixpkgs version with pre-built Rust binary)
              blink-cmp
              blink-cmp-words
              luasnip
              friendly-snippets

              # UI
              catppuccin-nvim
              lualine-nvim
              heirline-nvim
              noice-nvim
              nui-nvim
              nvim-notify
              which-key-nvim
              snacks-nvim
              mini-nvim

              # Editor
              nvim-treesitter.withAllGrammars
              nvim-treesitter-textobjects
              flash-nvim
              nvim-autopairs
              nvim-surround
              comment-nvim
              todo-comments-nvim
              vim-sleuth
              nvim-colorizer-lua
              oil-nvim
              diffview-nvim

              # Git
              gitsigns-nvim

              # LSP
              nvim-lspconfig
              lspsaga-nvim
              conform-nvim

              # DAP
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
              nvim-dap-python
              nvim-nio

              # Task runner
              overseer-nvim
              toggleterm-nvim

              # Filetype specific
              vimtex
              typst-vim
              vim-tmux-navigator

              # Extra
              switch-vim
              bullets-vim
            ];
          };

          optionalPlugins = {
            general = with pkgs.vimPlugins; [ ];
          };

          sharedLibraries = {
            general = with pkgs; [
              # For treesitter
            ];
          };

          environmentVariables = {
            general = {
              # For debugpy - will be overridden by direnv if available
              DEBUGPY_PATH = "${pkgs.python312Packages.debugpy}/lib/python3.12/site-packages/debugpy";
            };
          };

          extraWrapperArgs = { };

          python3.libraries = {
            general =
              ps: with ps; [
                debugpy
                pynvim
              ];
          };

          extraLuaPackages = {
            general = ps: with ps; [ ];
          };
        };

      packageDefinitions = {
        nvim =
          { pkgs, ... }:
          {
            settings = {
              # IMPORTANT: suffix-path adds Nix packages to END of PATH
              # This allows direnv LSPs to take priority
              suffix-path = true;
              suffix-LD = true;
              wrapRc = true;
              aliases = [
                "vim"
                "vi"
              ];
              neovim-unwrapped = pkgs.neovim-nightly or pkgs.neovim-unwrapped;
            };
            categories = {
              general = true;
              gitPlugins = true;
            };
          };

        # Development version with unwrapped config for hot reload
        nvim-dev =
          { pkgs, ... }:
          {
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = false; # Hot reload - uses ~/.config/nvim
              aliases = [ ];
              neovim-unwrapped = pkgs.neovim-nightly or pkgs.neovim-unwrapped;
            };
            categories = {
              general = true;
              gitPlugins = true;
            };
          };
      };

      defaultPackageName = "nvim";
    in
    forEachSystem (
      system:
      let
        nixCatsBuilder = utils.baseBuilder luaPath {
          inherit
            nixpkgs
            system
            dependencyOverlays
            extra_pkg_config
            ;
        } categoryDefinitions packageDefinitions;
        defaultPackage = nixCatsBuilder defaultPackageName;
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = utils.mkAllWithDefault defaultPackage;

        devShells = {
          default = pkgs.mkShell {
            name = defaultPackageName;
            packages = [ defaultPackage ];
            shellHook = ''
              echo "NichNvim development shell"
            '';
          };
        };
      }
    )
    // (
      let
        nixosModule = utils.mkNixosModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
        homeModule = utils.mkHomeModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
      in
      {
        overlays = utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions defaultPackageName;

        nixosModules.default = nixosModule;
        homeModules.default = homeModule;

        inherit utils nixosModule homeModule;
        inherit (utils) templates;
      }
    );
}
