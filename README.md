# PlantUML Neovim Plugin

A Neovim plugin for creating, rendering, and previewing UML diagrams directly from `.puml` files. This plugin integrates with [PlantUML](https://plantuml.com/) and provides an efficient workflow for working with UML diagrams.

---

## Features
- **Seamless UML Rendering**: Automatically render UML diagrams from `.puml` files.
- **Auto-Refresh**: Render diagrams on file save (optional).
- **Cross-Platform Compatibility**: Works on macOS, Linux, and Windows (planned future enhancements for non-macOS systems).
- **Simple Workflow**: Write UML in `.puml` files and preview the rendered diagrams with a single command.

---

## Installation

### Prerequisites
1. **PlantUML**:
   - Install PlantUML:
     ```bash
     brew install plantuml # macOS
     sudo apt install plantuml # Ubuntu
     ```
   - Ensure `plantuml` is available in your `PATH`.

2. **Java**:
   - Install Java (required by PlantUML):
     ```bash
     brew install openjdk # macOS
     sudo apt install default-jre # Ubuntu
     ```

3. **Neovim**:
   - Requires Neovim 0.10+ with Lua support.

4. 3rd/image.nvim 
  - link [3rd/image.nvim](https://github.com/3rd/image.nvim/tree/master)
  - minimal configuration required
	```lua
	return {
	  {
		"3rd/image.nvim",
		build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
		opts = {
		  processor = "magick_cli",
		},
	  },
	}
	```


### Plugin Installation

Using [LazyVim](https://www.lazyvim.org/configuration/plugins):

```lua
return {
  {
    "RajGupta18/nvim-plantuml",
	branch = "dev-raj",
    requires = { '3rd/image.nvim' },
	ft = "plantuml",
	init = function ()
		vim.filetype.add({
		extension = {
		  puml = "plantuml"
		},
	  })
	end,
    config = function()
      require("plantuml").setup({
        output_dir = "/tmp",					-- Directory to store rendered diagrams
        viewer = "gwenview",					-- External Image Viewer, used only when preview_mode = 'external'
        auto_refresh = true,					-- Enable/Disable auto-refresh on save
		preview_mode = "nvim"					-- `nvim` (default for inbuilt preview) or `external`
      })
    end,
  },
}
```

---

## Configuration

The plugin can be configured by calling the `setup` function with the following options:

```lua
require('plantuml').setup({
    output_dir = '/tmp',                   -- Directory to store rendered diagrams
    viewer = 'open',                       -- Command to open rendered diagrams (e.g., `open` for macOS)
    auto_refresh = true,                   -- Enable or disable auto-refresh on save
})
```

### Default Configuration
If no configuration is provided, the following defaults are used:

```lua
{
    output_dir = '/tmp',
    viewer = 'open',
    auto_refresh = false,
}
```

---

## Usage

### Commands

| Command             | Description                                      |
|---------------------|--------------------------------------------------|
| `:PlantUML preview`  | Render and preview the current `.puml` file.     |
| :PlantUML export <format> | Render and export the current .puml file with supported format png/svg | 

### Workflow
1. Open or create a `.puml` file in Neovim:
   ```text
   @startuml
   Alice -> Bob: Hello Bob
   Bob --> Alice: Hi Alice
   @enduml
   ```

2. Run the `:PlantUML preview` command to render and preview the diagram.
3. Save the file (`:w`) to trigger auto-refresh (if enabled).

---

## Roadmap

### Short-Term Goals
- [x] Basic rendering of `.puml` files using PlantUML.
- [x] Auto-refresh support.
- [x] Cross-platform compatibility for macOS.
- [ ] Improve error handling and diagnostics.

### Medium-Term Goals
- [ ] Add support for opening rendered diagrams in platform-specific viewers (e.g., Windows Photo Viewer).
- [ ] Allow rendering to multiple formats (SVG, PDF).
- [ ] Add inline ASCII diagram previews in Neovim.

### Long-Term Goals
- [ ] Interactive UML editing directly within Neovim.
- [x] Real-time rendering as you type.
- [ ] Syntax highlighting for `.puml` files.
- [ ] Integration with external diagram storage services.

---

## Troubleshooting

### PlantUML Not Found
Ensure that `plantuml` is installed and available in your `PATH`. Test it by running:
```bash
plantuml -version
```

### Java Not Installed
Install Java and ensure it is available in your `PATH`. Test it by running:
```bash
java -version
```

### Diagrams Not Opening
Ensure the configured `viewer` command works. Test it manually:
```bash
open /path/to/diagram.png # macOS
```

---

## Contributing
Contributions are welcome! If you encounter bugs or have feature suggestions, feel free to open an issue or submit a pull request.

---

## License
This plugin is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments
- [PlantUML](https://plantuml.com/)
- [Neovim](https://neovim.io/)


