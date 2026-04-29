# 🚀 My Neovim Configuration (Nightly 0.12+)

A high-performance, IDE-like Neovim setup optimized for **ReactJS**, **Laravel/PHP**, **Bun**, and **Rust**.

---

## 🎹 Custom Shortcuts

### 📁 File Management
| Shortcut | Action |
| :--- | :--- |
| `<C-b>` | Toggle File Explorer (NvimTree) |
| `<C-n>` | Create New File (automatically creates directories if needed) |
| `<C-f>` | Create New Folder |
| `<leader>fb` | Open Telescope File Browser |
| `<leader>bf` | Open Telescope File Browser (Alias) |
| `gf` | Go to file under cursor |
| `<leader>gf` | Go to file under cursor in a new split |

### 🔍 Navigation & Search (Telescope)
| Shortcut | Action |
| :--- | :--- |
| `<C-p>` | Find Files (searches from Project Root) |
| `<C-l>` | Live Grep (Full-text search across project) |
| `ll` | Find and switch between open Buffers |
| `<C-m>` | List Document Symbols (functions, variables in current file) |
| `<leader>m` | List Workspace Symbols (symbols across the whole project) |
| `<leader>fh` | Search Neovim Help Tags |

### ⚡ LSP & Development
| Shortcut | Action |
| :--- | :--- |
| `gd` | Go to Definition |
| `K` | Hover Documentation (show type info/docs in a popup) |
| `gr` | List References of the symbol under cursor |
| `<leader>rn` | Rename Symbol (project-wide) |
| `<leader>ca` | Open Code Actions (fixes, refactors) |
| `<leader>mp` | Format Buffer (using Conform - supports Prettier, Rustfmt, etc.) |
| `<leader>th` | Toggle Inlay Hints (Inline type/parameter hints) |
| `<leader>bt` | **Run Tests** (Auto-detects Bun or Cargo/Rust in a floating window) |
| `<leader>br` | **Run Project** (Auto-detects Bun or Cargo/Rust in a floating window) |
| `<leader>bb` | **Build Project** (Auto-detects Bun or Cargo/Rust in a floating window) |
| `<leader>bc` | **Check Project** (Auto-detects Bun or Cargo/Rust in a floating window) |
| `<leader>rr` | Run HTTP request under cursor (REST client) |
| `<leader>rp` | Run last HTTP request |

### 📦 JS/TS Specialized (vtsls)
| Shortcut | Action |
| :--- | :--- |
| `<leader>oi` | Organize Imports (Removes unused, sorts remaining) |
| `<leader>fa` | Fix All (Applies all available automated fixes) |
| `<leader>rf` | Rename File (Automatically updates all imports in the project) |

### 🐘 Laravel Specialized (only active in Laravel projects)
| Shortcut | Action |
| :--- | :--- |
| `<leader>la` | Laravel Artisan (Interactive command runner) |
| `<leader>lr` | Laravel Routes (List and search routes) |
| `<leader>lm` | Laravel Related Files (Quick jump between Model ↔ View ↔ Controller) |

### 📑 Buffer & Window Management
| Shortcut | Action |
| :--- | :--- |
| `S-h` / `C-[` | Previous Buffer |
| `S-l` / `C-]` | Next Buffer |
| `<leader>x` | Close Current Buffer (Instant) |
| `<leader>bd` | Close Current Buffer (via Bufferline) |
| `<C-s>` / `<leader>w` | Save File |
| `<C-q>` / `<leader>q` | Quit current window |
| `<leader>Q` | Force quit all windows |

### 📝 Editing & Movement
| Shortcut | Action |
| :--- | :--- |
| `Alt + j` | Move current line **Down** (Normal Mode) |
| `Alt + k` | Move current line **Up** (Normal Mode) |
| `J` (in Visual) | Move selection **Down** |
| `K` (in Visual) | Move selection **Up** |
| `J` (in Normal)| Join lines while keeping cursor position |
| `<C-d>` / `<C-u>` | Half-page Down/Up and center cursor |
| `n` / `N` | Next/Previous search result and center cursor |
| `<C-a>` | Select All text |
| `<C-c>` | Copy selection to System Clipboard |
| `gc` | Toggle Line Comment |
| `gb` | Toggle Block Comment |
| `<Esc>` | Clear search highlighting |
| `<leader>?` | Show all available keymaps (WhichKey) |

### 🐛 Diagnostics & Debugging
| Shortcut | Action |
| :--- | :--- |
| `<leader>Dx` | Open Trouble Diagnostics (Project-wide) |
| `<leader>DX` | Open Buffer-only Diagnostics |
| `<leader>e` | Open Floating Diagnostic (detailed error message) |
| `[d` / `]d` | Jump to Previous/Next Diagnostic |
| `<leader>db` | Toggle Debug Breakpoint |
| `<leader>dc` | Debug Continue |
| `<leader>do` | Debug Step Over |
| `<leader>di` | Debug Step Into |
| `<leader>du` | Debug Step Out |

---

## ✨ Features & Optimizations

- **Modern Diagnostics:** Uses `tiny-inline-diagnostic.nvim` for beautiful, non-disruptive inline error messages.
- **Auto-Imports:** Powered by `vtsls` for JS/TS and `intelephense` for PHP.
- **Enhanced Rust Support:** Uses `rustaceanvim` for a superior Rust development experience, including clippy-based diagnostics, better inlay hints, and `crates.nvim` for managing dependencies in `Cargo.toml`.
- **Auto-Tagging:** `nvim-ts-autotag` handles JSX/HTML tag closing and renaming.
- **REST Client:** `rest.nvim` integrated for testing APIs directly in `.http` or `.rest` files.
- **Multi-language Testing:** Smart `<leader>bt` detects project type to run `bun test` or `cargo test`.
- **Stability Fixes:**
    - Disabled LSP Semantic Tokens to prevent color flickering.
    - Switched Tree-sitter to `main` branch for Neovim 0.12 compatibility.
    - Automatic `redraw!` after shell commands to fix vanishing colors.

---

## 🛠️ Troubleshooting & Dependencies

If you see warnings in `:checkhealth`, you may need to install these external dependencies:

### Required for full functionality:
- **Tree-sitter CLI:** `npm install -g tree-sitter-cli` (fixes Treesitter errors)
- **Rust Debugging:** Install `codelldb` via Mason (`:MasonInstall codelldb`) for debugging support.
- **Luasnip Transformations:** `brew install jsregexp` (optional, for complex snippets).

### Notes on Providers:
Node.js, Python, and Ruby providers are currently **disabled** in `init.lua` to prevent startup warnings since they require additional global packages (like `npm install -g neovim`). If you need them, re-enable them in `init.lua`.

