# Neovim Configuration

This is my personal Neovim configuration, built on top of [AstroNvim](https://astronvim.com/). This configuration provides a modern, feature-rich Neovim setup with a focus on productivity and ease of use.

## 🚀 Features

### Core Features
- Modern UI with icons and beautiful colorschemes (Tokyo Night)
- Lazy loading of plugins for faster startup
- LSP support for intelligent code completion
- Telescope for fuzzy finding
- Treesitter for better syntax highlighting
- Git integration with Blamer.nvim
- Terminal integration
- Project management with ProjectMgr.nvim
- Smart file opening with smart-open.nvim
- Task management with vs-tasks.nvim
- Note-taking capabilities with zk-nvim
- Code navigation with NavBuddy
- Leap for quick navigation
- Scrollbar for better visibility
- Buffer management with bufferline.nvim
- Tab management with tabby.nvim

### UI Enhancements
- Custom dashboard with ASCII art header
- Indent blankline for better code structure visualization
- Mini map for code overview
- Scrollbar for better navigation
- Buffer line for tab management
- Tokyo Night theme for beautiful colors

## ⌨️ Key Mappings

### Leader Key
The leader key is set to `<Space>`. Here are the key mappings from your configuration:

#### Custom Mappings (from mappings.lua)
- `<Space><Space>` - Smart Open (opens recent files)
- `<Space>P` - Open Project Manager
- `<Space>bn` - New tab
- `<Space>bD` - Pick buffer to close
- `K` - Hover symbol details (LSP)
- `gD` - Go to declaration (LSP, when available)

#### Buffer Navigation (Built-in)
- `]b` - Next buffer
- `[b` - Previous buffer

### Default AstroNvim Mappings
Your configuration inherits several default mappings from AstroNvim:

#### Telescope
- `<Space>ff` - Find files
- `<Space>fg` - Live grep
- `<Space>fb` - Find buffers
- `<Space>fh` - Find help tags

#### LSP
- `gd` - Go to definition
- `gr` - Go to references
- `<Space>ca` - Code actions
- `<Space>rn` - Rename symbol

#### Git
- `<Space>gg` - Open Git status
- `<Space>gl` - Open Git log
- `<Space>gb` - Open Git blame

#### Terminal
- `<Space>h` - Toggle terminal
- `<C-\>` - Toggle terminal (alternative)

#### File Operations
- `<Space>e` - Toggle file explorer
- `<Space>w` - Save file
- `<Space>q` - Quit Neovim
- `<Space>Q` - Force quit

#### Search and Replace
- `<Space>sw` - Search word under cursor
- `<Space>sr` - Search and replace
- `<Space>sl` - Search in current line

#### Code Actions
- `<Space>ca` - Code actions
- `<Space>rn` - Rename symbol
- `<Space>f` - Format code
- `<Space>d` - Show diagnostics

#### Debugging
- `<Space>db` - Toggle breakpoint
- `<Space>dc` - Continue debugging
- `<Space>ds` - Step over
- `<Space>di` - Step into
- `<Space>do` - Step out

### Standard Neovim Window Commands
Since your configuration doesn't include custom window/pane mappings, you can use standard Neovim commands:
- `:split` - Split horizontally
- `:vsplit` - Split vertically
- `:close` - Close current window
- `:only` - Close other windows
- `Ctrl+w h` - Move to left window
- `Ctrl+w j` - Move to bottom window
- `Ctrl+w k` - Move to top window
- `Ctrl+w l` - Move to right window
- `Ctrl+w +` - Increase window height
- `Ctrl+w -` - Decrease window height
- `Ctrl+w >` - Increase window width
- `Ctrl+w <` - Decrease window width
- `Ctrl+w =` - Equalize window sizes

## 🛠️ Requirements

### Core Requirements
- Neovim >= 0.9.0
- A Nerd Font (for icons)
- Git
- Node.js (for LSP support)
- Python (for some plugins)

### Optional Dependencies
- SQLite (for smart-open.nvim)
- zk (for note-taking)
- Telescope fzf native (for better fuzzy finding)

## 📦 Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/nvim-config.git ~/.config/nvim
```

2. Start Neovim and wait for the plugins to install:
```bash
nvim
```

## 🔧 Configuration

The configuration is organized into several files:
- `init.lua` - Main entry point
- `lua/lazy_setup.lua` - Plugin management with Lazy.nvim
- `lua/polish.lua` - Additional configurations and customizations
- `lua/plugins/` - Directory containing plugin configurations:
  - `user.lua` - Custom plugins and their configurations
  - `mason.lua` - LSP and formatter installations
  - `treesitter.lua` - Syntax highlighting configuration
  - `astrolsp.lua` - LSP configuration
  - `mappings.lua` - Custom key mappings

## 🎨 Customization

### Adding New Plugins
Add new plugins in `lua/plugins/user.lua`:
```lua
return {
  "author/plugin-name",
  {
    "author/plugin-name",
    config = function()
      require("plugin-name").setup({
        -- configuration options
      })
    end,
  },
}
```

### Modifying Key Mappings
Key mappings can be modified in `lua/plugins/mappings.lua` or within individual plugin configurations.

### Changing Theme
The theme can be changed by modifying the configuration in `lua/plugins/user.lua`:
```lua
{
  "folke/tokyonight.nvim",
  opts = {
    -- theme options
  },
}
```

## 📚 Additional Resources

### Documentation
- [AstroNvim Documentation](https://astronvim.com/)
- [Neovim Documentation](https://neovim.io/doc/)
- [Lazy.nvim Documentation](https://github.com/folke/lazy.nvim)

### Plugin Documentation
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [LSP Config](https://github.com/neovim/nvim-lspconfig)
- [Mason](https://github.com/williamboman/mason.nvim)

## 🤝 Contributing

Feel free to submit issues and enhancement requests! When contributing:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This configuration is open source and available under the MIT License.
