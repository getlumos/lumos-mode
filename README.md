# lumos-mode

Emacs major mode for [LUMOS](https://lumos-lang.org) - a type-safe schema language for Solana development.

[![MELPA](https://melpa.org/packages/lumos-mode-badge.svg)](https://melpa.org/#/lumos-mode)
[![CI](https://github.com/getlumos/lumos-mode/workflows/CI/badge.svg)](https://github.com/getlumos/lumos-mode/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE-MIT)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE-APACHE)

## Features

✅ **Syntax Highlighting** - Keywords, types, attributes, comments
✅ **Smart Indentation** - Context-aware auto-indent
✅ **LSP Integration** - Auto-completion, diagnostics, hover, go-to-definition via [lumos-lsp](https://github.com/getlumos/lumos)
✅ **Comment Support** - Line (`//`) and block (`/* */`) comments
✅ **File Association** - Automatic detection of `.lumos` files

## Installation

### Prerequisites

1. **Emacs 26.1+** - `M-x version` to check
2. **lumos-lsp server** - LSP features require the LUMOS Language Server:

```bash
cargo install lumos-lsp
```

3. **lsp-mode** - For LSP integration (optional but recommended):

```elisp
(use-package lsp-mode
  :ensure t)
```

### Option 1: MELPA (Recommended)

```elisp
(use-package lumos-mode
  :ensure t
  :hook (lumos-mode . lsp-deferred))
```

### Option 2: straight.el

```elisp
(use-package lumos-mode
  :straight (lumos-mode :type git :host github :repo "getlumos/lumos-mode")
  :hook (lumos-mode . lsp-deferred))
```

### Option 3: Manual Installation

1. Clone this repository:

```bash
git clone https://github.com/getlumos/lumos-mode.git ~/.emacs.d/lisp/lumos-mode
```

2. Add to your Emacs config:

```elisp
;; Add to load path
(add-to-list 'load-path "~/.emacs.d/lisp/lumos-mode")

;; Load mode
(require 'lumos-mode)

;; Enable LSP (optional)
(add-hook 'lumos-mode-hook #'lsp-deferred)
```

## Usage

### Basic Editing

Open any `.lumos` file and `lumos-mode` will activate automatically:

```elisp
;; Open a LUMOS file
M-x find-file RET schema.lumos RET
```

### Syntax Highlighting

`lumos-mode` automatically highlights:

- **Keywords**: `struct`, `enum`
- **Types**: `u64`, `PublicKey`, `Vec`, `Option`, etc.
- **Attributes**: `#[solana]`, `#[account]`, `#[version]`, `#[deprecated]`
- **Comments**: `//` and `/* */`
- **Field names**: Identifiers before colons
- **String literals**: Text in quotes

### LSP Features

With `lsp-mode` and `lumos-lsp` installed, you get:

#### Auto-completion

Type and press `M-TAB` (or configure `company-mode` for automatic suggestions):

```
struct Player {
  wal<cursor>  ← Press M-TAB to see completions
}
```

#### Diagnostics

Syntax errors appear inline with `flycheck`:

```
struct Player {
  wallet: UnknownType  ← Error: Undefined type 'UnknownType'
}
```

#### Hover Documentation

Press `M-x lsp-describe-thing-at-point` or hover over a symbol:

```
PublicKey  ← Hover shows: "Solana PublicKey (32 bytes)"
```

#### Go to Definition

Press `M-.` to jump to definition:

```
player: Player  ← M-. jumps to 'struct Player' definition
```

#### Find References

Press `M-?` to find all references to a symbol.

#### Rename Symbol

Press `M-x lsp-rename` to rename a symbol across all files.

#### Code Actions

Press `M-x lsp-execute-code-action` to see available code actions.

### Indentation

`lumos-mode` provides smart indentation:

```elisp
;; Auto-indent on newline
struct Player {
  wallet: PublicKey,  ← Press RET, cursor auto-indents
}

;; Manual indent
M-x indent-region  ← Indent selected region
```

Customize indent width:

```elisp
(setq lumos-indent-offset 4)  ; Default: 2
```

### Comments

#### Toggle Comment

Select a region and press `M-;` to comment/uncomment:

```
struct Player {}  ← Select and M-; → // struct Player {}
```

#### Insert Comment

Type `//` for line comments or `/* */` for block comments:

```
// This is a line comment

/*
 * This is a block comment
 */
```

## Configuration

### Full Configuration Example

```elisp
(use-package lumos-mode
  :ensure t
  :custom
  ;; Customize LSP server command
  (lumos-lsp-server-command '("lumos-lsp" "--log-level" "debug"))

  ;; Customize indentation
  (lumos-indent-offset 4)

  :hook
  ;; Enable LSP
  ((lumos-mode . lsp-deferred)

   ;; Enable auto-completion
   (lumos-mode . company-mode)

   ;; Enable syntax checking
   (lumos-mode . flycheck-mode))

  :config
  ;; Custom keybindings
  (define-key lumos-mode-map (kbd "C-c C-c") 'lsp-execute-code-action)
  (define-key lumos-mode-map (kbd "C-c C-r") 'lsp-rename)
  (define-key lumos-mode-map (kbd "C-c C-f") 'lsp-format-buffer))
```

### Keybindings (with lsp-mode)

| Key         | Command                | Description                |
|-------------|------------------------|----------------------------|
| `M-.`       | `lsp-find-definition`  | Go to definition           |
| `M-?`       | `lsp-find-references`  | Find references            |
| `M-TAB`     | `completion-at-point`  | Auto-complete              |
| `C-c C-r`   | `lsp-rename`           | Rename symbol              |
| `C-c C-c`   | `lsp-execute-code-action` | Execute code action     |
| `C-c C-f`   | `lsp-format-buffer`    | Format buffer              |
| `M-;`       | `comment-dwim`         | Comment/uncomment region   |

### Customizable Variables

```elisp
;; LSP server command
(setq lumos-lsp-server-command '("lumos-lsp"))

;; Indentation width
(setq lumos-indent-offset 2)
```

## Example LUMOS File

Create a file `example.lumos`:

```rust
#[solana]
#[account]
struct PlayerAccount {
  wallet: PublicKey,
  level: u16,
  experience: u64,
  inventory: Vec<Item>,
}

#[solana]
struct Item {
  id: u32,
  name: String,
  quantity: u16,
}

#[solana]
enum GameState {
  Lobby,
  Playing { round: u32 },
  Finished,
}
```

Open in Emacs:

```bash
emacs example.lumos
```

You'll get syntax highlighting, auto-completion, and diagnostics automatically!

## Troubleshooting

### LSP server not starting

**Problem**: No auto-completion or diagnostics.

**Solution**:

1. Check `lumos-lsp` is installed:
   ```bash
   which lumos-lsp
   ```

2. Check LSP is running:
   ```elisp
   M-x lsp-describe-session
   ```

3. View LSP logs:
   ```elisp
   M-x lsp-workspace-show-log
   ```

4. Restart LSP:
   ```elisp
   M-x lsp-workspace-restart
   ```

### Syntax highlighting not working

**Problem**: No colors in `.lumos` files.

**Solution**:

1. Check mode is active:
   ```elisp
   M-: major-mode RET  ; Should show 'lumos-mode'
   ```

2. Force font-lock refresh:
   ```elisp
   M-x font-lock-fontify-buffer
   ```

### Indentation issues

**Problem**: Wrong indentation levels.

**Solution**:

1. Check indent offset:
   ```elisp
   M-: lumos-indent-offset RET  ; Should show 2 (default)
   ```

2. Manually indent region:
   ```elisp
   C-x h              ; Select all
   M-x indent-region  ; Re-indent
   ```

### File not using lumos-mode

**Problem**: `.lumos` file opens in fundamental-mode.

**Solution**:

1. Check file association:
   ```elisp
   M-: (assoc "\\.lumos\\'" auto-mode-alist) RET
   ```

2. Manually activate:
   ```elisp
   M-x lumos-mode
   ```

3. Reload config and restart Emacs.

## Development

### Testing

We have three levels of testing to ensure production quality:

#### 1. Unit Tests (14 tests)

Test individual components (syntax highlighting, indentation, comments, etc.)

```bash
# Quick test
make test

# Or manually
emacs -batch -l lumos-mode.el -l lumos-mode-test.el -f ert-run-tests-batch-and-exit
```

**Coverage:**
- Mode loading and derivation
- File association (`.lumos` → `lumos-mode`)
- Syntax highlighting (keywords, types, attributes, comments)
- Indentation (structs, enums, nested blocks)
- Comment functionality (line and block)
- Custom variables

#### 2. Integration Tests

Test Emacs compatibility and package integration:

```bash
./test-integration.sh
```

**Tests:**
- ✓ Emacs version compatibility (26.1+)
- ✓ Unit test suite execution
- ✓ Byte compilation
- ✓ lumos-lsp server detection
- ✓ Mode loading in Emacs
- ✓ File association automation
- ✓ Syntax highlighting rules
- ✓ Indentation function
- ✓ Custom variables
- ✓ Package-lint validation

#### 3. End-to-End Tests

Test real user workflows:

```bash
./test-e2e.sh
```

**Simulates:**
- User installation via straight.el
- Opening `.lumos` files
- Syntax highlighting in action
- Indentation behavior
- Comment insertion
- Custom variable configuration
- LSP integration (if `lumos-lsp` available)

#### Run All Tests

Before MELPA submission or major changes:

```bash
./test-all.sh
```

This runs all three test suites and reports overall status.

### Continuous Integration

GitHub Actions automatically runs all tests on every push:

- **Emacs Versions:** 27.2, 28.2, 29.1, snapshot
- **Checks:** Tests, byte compilation, package-lint
- **Status:** See [Actions tab](https://github.com/getlumos/lumos-mode/actions)

### Byte Compilation

```bash
# Compile to bytecode
make compile

# Clean compiled files
make clean
```

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Run tests: `make test`
4. Submit a pull request

## Related Projects

- [lumos](https://github.com/getlumos/lumos) - Core compiler and CLI
- [vscode-lumos](https://github.com/getlumos/vscode-lumos) - VS Code extension
- [intellij-lumos](https://github.com/getlumos/intellij-lumos) - IntelliJ IDEA plugin
- [nvim-lumos](https://github.com/getlumos/nvim-lumos) - Neovim plugin
- [tree-sitter-lumos](https://github.com/getlumos/tree-sitter-lumos) - Tree-sitter grammar
- [awesome-lumos](https://github.com/getlumos/awesome-lumos) - Examples and templates

## Resources

- **Website**: [lumos-lang.org](https://lumos-lang.org)
- **Documentation**: [docs](https://lumos-lang.org/guide/)
- **GitHub**: [getlumos](https://github.com/getlumos)
- **Examples**: [awesome-lumos](https://github.com/getlumos/awesome-lumos)

## License

Dual-licensed under [MIT](LICENSE-MIT) and [Apache 2.0](LICENSE-APACHE).
