# My Emacs Configuration

A comprehensive Emacs configuration focused on Python, C++, and Go development with modern IDE-like features.

## Quick Start

```bash
git clone https://github.com/slgao/emacs.d.git ~/.emacs.d
```

Start Emacs and the configuration will automatically install required packages on first run.

Then complete the one-time manual setup steps described below for each language/tool you use.

## Features

### Core IDE Features
- **Auto-completion**: Company mode with LSP backends (manual trigger: `C-c c`)
- **Syntax checking**: Flycheck with language-specific linters
- **Project management**: Projectile + counsel-projectile — fuzzy find file in project (`C-c p f`), switch project (`C-c p p`)
- **Project-wide search**: counsel-rg live grep (`M-s r`, requires ripgrep)
- **Keybinding discovery**: which-key shows available bindings after any prefix
- **Version control**: Magit integration plus diff-hl change markers in the fringe
- **Hover docs & peek**: lsp-ui — documentation popup at point after the cursor rests, peek-style reference view (`M-?`), diagnostics/code actions in the sideline
- **Debugging**: dap-mode with VS Code debug adapters (`M-x dap-debug`; Python via debugpy, Go via delve)
- **Terminal**: vterm on `C-c v` (Linux/macOS; falls back to eshell on Windows)
- **Navigation**: Ivy/Counsel/Swiper fuzzy searching, line numbers in code buffers
- **Window management**: Ace-window for quick window switching
- **Multiple cursors**: Edit multiple locations simultaneously
- **Performance**: GC tuned for lsp-mode; slow minor modes auto-disabled in files >100KB

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

### TypeScript/JavaScript Development
- **LSP mode**: via `typescript-language-server` for `.ts` files (tsgo is disabled for compatibility)
- **js2-mode**: for `.js`/`.mjs` files with xref navigation
- **web-mode**: for `.tsx`/`.jsx` and HTML templates

### AI Assistance
- **GitHub Copilot**: Inline completions in Python, C/C++, Go, TypeScript, shell, YAML, and Terraform
  - Accept completion: `C-M-<return>`
  - Next/previous suggestion: `C-M-<next>` / `C-M-<prior>`
  - Accept by word: `C-M-<right>`
  - Accept by line: `C-M-<down>`
  - Clear overlay: `C-c C-c`

### UI/UX Enhancements
- **Themes**: Gruvbox (default) and Monokai
- **Per-OS font**: Ubuntu Mono on Linux, Monaco on macOS, Consolas on Windows (edit in `lisp/init-ui.el`)
- **Smart defaults**: Sensible configuration out of the box
- **Custom keybindings**: Optimized workflow shortcuts
- **Visual indicators**: Line numbers, line highlighting, parentheses matching
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
- `C-c c` - Manually trigger company completion
- `C-c f` - Open current directory in OS file manager
- `C-c r` - Revert (reload) current buffer
- `C-x g` - Magit status

### Project (Projectile)
- `C-c p f` - Find file in project (fuzzy, like VS Code Ctrl+P)
- `C-c p p` - Switch project
- `C-c p` + wait - which-key shows all project commands
- `M-s r` - Live grep across project (counsel-rg, needs ripgrep)

### Development
- `M-.` - Go to definition (via lsp-mode / xref)
- `M-,` - Go back after jump
- `C-c l` - LSP command prefix (rename, code actions, ... — which-key lists them)
- `M-?` - Peek references (lsp-ui) in LSP buffers
- `C-c v` - Open terminal (vterm; eshell on Windows)
- `M-s i` - Browse symbols in current file (counsel-imenu, LSP-enriched)
- `M-s I` - Search symbols across entire project (lsp-ivy workspace)
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

### TypeScript (lsp-mode)

```bash
npm install -g typescript-language-server typescript
```

No further Emacs configuration needed — lsp-mode auto-starts for `.ts` files.

### Terminal (vterm) — Linux/macOS only

vterm compiles a native module on first launch and needs build tools installed:

```bash
# Linux
sudo apt install cmake libtool-bin libvterm-dev

# macOS
brew install cmake libvterm libtool
```

Not supported on native Windows Emacs — `C-c v` opens eshell there instead.

### Debugging (dap-mode)

For Python, install debugpy in the environment you debug:
```bash
pip install debugpy
```

Go debugging uses delve:
```bash
go install github.com/go-delve/delve/cmd/dlv@latest
```

Start a session with `M-x dap-debug`.

### Project search (ripgrep)

```bash
# Linux
sudo apt install ripgrep

# macOS
brew install ripgrep

# Windows
winget install BurntSushi.ripgrep.MSVC
```

### Terraform (lsp-mode)

Install the Terraform LSP server:
```bash
# Download terraform-ls from https://github.com/hashicorp/terraform-ls/releases
# and place the binary somewhere on your PATH
```

### Go (go-mode + gopls)

1. Install Go from https://go.dev/dl/
2. Install the Go language server:
   ```bash
   go install golang.org/x/tools/gopls@latest
   ```

No further Emacs configuration needed — lsp-mode auto-starts, `gofmt`/`goimports` runs on save, and Copilot is active in `go-mode` buffers.

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

- Emacs 27+ (29+ recommended for native compilation)
- Git
- ripgrep (for project-wide search, `M-s r`)
- Python 3.6+ with pip
- Node.js 18+ and npm (for Copilot and typescript-language-server)
- Clang (for C++ development)
- CMake (for C++ project management)
- Go 1.18+ with `gopls` (for Go development)
- cmake + libtool + libvterm (for vterm terminal, Linux/macOS only)
- debugpy / delve (for interactive debugging via dap-mode)

## License

This configuration is provided as-is for educational and personal use.
