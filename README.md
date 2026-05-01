# My Emacs Configuration

A comprehensive Emacs configuration focused on Python and C++ development with modern IDE-like features.

## Quick Start

```bash
git clone https://github.com/slgao/emacs.d.git ~/.emacs.d
```

Start Emacs and the configuration will automatically install required packages on first run.

Then complete the one-time manual setup steps described below for each language/tool you use.

## Features

### Core IDE Features
- **Auto-completion**: Company mode with intelligent backends
- **Syntax checking**: Flycheck with language-specific linters
- **Project navigation**: Ivy/Counsel/Swiper for fuzzy searching
- **Version control**: Magit integration for Git
- **Window management**: Ace-window for quick window switching
- **File management**: Enhanced Dired with dired+
- **Multiple cursors**: Edit multiple locations simultaneously

### Python Development
- **LSP mode**: Full IDE experience via `pylsp` (goto-definition, completion, diagnostics)
- **Virtual environment support**: pyvenv for environment switching
- **Code formatting**: py-autopep8 with customizable line length (100 chars)
- **Documentation**: Sphinx-doc mode for docstring generation
- **Linting**: Flake8 integration via Flycheck

### C/C++ Development
- **Irony mode**: Clang-based completion and syntax checking
- **Company-irony**: Intelligent auto-completion
- **CMake support**: CMake mode for build configuration
- **Code formatting**: Clang-format integration
- **Flycheck-irony**: Real-time syntax checking
- **Helm-gtags**: Code navigation and symbol lookup

### AI Assistance
- **GitHub Copilot**: Inline completions in Python, C/C++, shell, YAML, and Terraform
  - Accept completion: `C-M-<return>`
  - Next/previous suggestion: `C-M-<next>` / `C-M-<prior>`
  - Accept by word: `C-M-<right>`
  - Accept by line: `C-M-<down>`
  - Clear overlay: `C-c C-c`

### UI/UX Enhancements
- **Themes**: Multiple themes available (Gruvbox default, Monokai, Zenburn, etc.)
- **Smart defaults**: Sensible configuration out of the box
- **Custom keybindings**: Optimized workflow shortcuts
- **Visual indicators**: Line highlighting, parentheses matching
- **Time display**: Date and time in mode line
- **Recent files**: Quick access to recently opened files

### Additional Tools
- **Org mode**: Enhanced with org-bullets and agenda integration
- **Terraform**: terraform-mode with LSP support
- **Web development**: Web-mode and Emmet for HTML/CSS
- **Git integration**: Magit for version control
- **Snippet expansion**: YASnippet support
- **Kill ring browser**: Enhanced clipboard management
- **Undo tree**: Visual undo/redo system
- **Neotree**: File tree sidebar with icons

## Configuration Structure

```
~/.emacs.d/
├── early-init.el              # Prevents package.el auto-init (loaded before init.el)
├── init.el                    # Entry point, loads org-babel config
├── shulins_emacs_config.org   # Main configuration in org-babel format
├── lisp/                      # Modular configuration files
│   ├── init-packages.el       # Package management and setup
│   ├── init-ui.el            # UI and theme configuration
│   ├── init-better-defaults.el # Sensible defaults
│   ├── init-keybindings.el   # Custom key bindings
│   ├── init-org.el           # Org mode configuration
│   ├── init-utils.org        # Utility functions
│   └── custom.el             # Emacs custom variables
├── site-lisp/                # Third-party packages
│   ├── nadvice_.el           # Extended advice system
│   ├── org-bullets.el        # Org mode visual enhancements
│   ├── dired+.el            # Enhanced directory editor
│   └── move-lines.el         # Line manipulation utilities
└── snippets/                 # YASnippet templates
```

## Key Bindings

### Global Shortcuts
- `F2` - Open init file
- `C-x C-r` - Recent files
- `C-s` - Swiper search
- `M-x` - Counsel M-x (enhanced command palette)
- `C-x C-f` - Counsel find file
- `C-x o` - Ace window (quick window switching)
- `C-c a` - Org agenda
- `M-/` - Hippie expand (smart completion)

### Development
- `M-.` - Go to definition (via lsp-mode / xref)
- `M-,` - Go back after jump
- `C-h C-f` - Find function definition
- `C-h C-v` - Find variable definition
- `C-h C-k` - Find function on key
- `C-M-\` - Indent region or buffer
- `C-:` - Avy goto word (quick navigation)

## Manual Setup

These steps must be completed once per machine after cloning.

### Python (lsp-mode via pylsp)

#### Linux / macOS
```bash
pip3 install python-lsp-server
```

#### Windows
```bash
pip install python-lsp-server
```

No further Emacs configuration needed — lsp-mode auto-starts when you open a Python file and `M-.` navigates to definitions.

To switch virtual environments at runtime use `M-x pyvenv-activate`.

### GitHub Copilot

#### Prerequisites — install Node.js and npm

| Platform | Command |
|----------|---------|
| Linux (Debian/Ubuntu) | `sudo apt-get install nodejs npm` |
| macOS | `brew install node` |
| Windows | Download from https://nodejs.org |

#### Install the Copilot language server (once per machine)

Inside Emacs:
```
M-x copilot-install-server
```

#### Authenticate with GitHub (once per machine)

Inside Emacs:
```
M-x copilot-login
```

Follow the device-auth prompt: copy the code shown in the minibuffer, open the URL in a browser, and paste the code. Copilot will activate automatically after login.

### C/C++ (irony + clang)

```bash
# Linux
sudo apt-get install clang cmake

# macOS
brew install llvm cmake
```

Inside Emacs, run once per project:
```
M-x irony-install-server
```

### Terraform (lsp-mode)

Install the Terraform LSP server:
```bash
# Download terraform-ls from https://github.com/hashicorp/terraform-ls/releases
# and place the binary somewhere on your PATH
```

## Package Management

Packages are managed via MELPA/ELPA (`package.el`). On first Emacs startup, all packages listed in `shulin/packages` in `lisp/init-packages.el` are installed automatically.

### Adding New Packages
1. Add the package name to `shulin/packages` in `lisp/init-packages.el`
2. Add configuration in the same file or create a new module
3. Restart Emacs

### Changing Themes
Edit `lisp/init-ui.el` and change the `load-theme` line:
```elisp
(load-theme 'your-preferred-theme t)
```

### Custom Keybindings
Add new bindings in `lisp/init-keybindings.el`.

## Troubleshooting

### `M-.` still shows "visit tags table" in Python
LSP mode failed to start. Check:
1. `pylsp` is installed and on PATH: `which pylsp`
2. Emacs can see it: `M-x eval-expression` → `(executable-find "pylsp")`
3. View LSP status: `M-x lsp-describe-session`

### Copilot "Not authenticated"
Run `M-x copilot-login` and complete the GitHub device-auth flow.

### Copilot "language server not installed"
Run `M-x copilot-install-server` (requires npm).

### Python Issues
- Switch virtual environment: `M-x pyvenv-activate`
- Check LSP server status: `M-x lsp-describe-session`

### C++ Issues
- Ensure clang is installed and accessible
- Provide `compile_commands.json` (via CMake with `CMAKE_EXPORT_COMPILE_COMMANDS=ON`)

## Requirements

- Emacs 26+
- Git
- Python 3.6+ with pip
- Node.js 18+ and npm (for Copilot)
- Clang (for C++ development)
- CMake (for C++ project management)

## License

This configuration is provided as-is for educational and personal use.
