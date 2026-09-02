local config = require("plantuml.config")

--- @dict PlantumlExportType
local PlantumlExportType = {
	"png",
	"svg",
}

local M = {}

M.exportType = PlantumlExportType

local function isPumlFile()
	return vim.fn.expand("%:e") == "puml"
end

local function notify(message, level)
	vim.notify(message, level, { title = "PlantUML" })
end

local function output_paths(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	local id = vim.fn.sha256(name):sub(1, 16)
	local base = config.output_dir:gsub("/+$", "") .. "/plantuml-" .. id
	return base .. ".puml", base .. ".png"
end

local function render(callback)
	if vim.fn.executable("plantuml") ~= 1 then
		notify("plantuml is not installed or not in PATH", vim.log.levels.ERROR)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local input, png = output_paths(bufnr)
	vim.fn.mkdir(config.output_dir, "p")

	local file, err = io.open(input, "w")
	if not file then
		notify("Could not write PlantUML source: " .. (err or input), vim.log.levels.ERROR)
		return
	end
	file:write(table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n"))
	file:close()

	vim.system({ "plantuml", "-tpng", input }, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 or vim.fn.filereadable(png) ~= 1 then
				notify(
					result.stderr ~= "" and result.stderr or "PlantUML failed to render the diagram",
					vim.log.levels.ERROR
				)
				return
			end
			callback(png)
		end)
	end)
end

local preview_state = {
	win = nil,
	buf = nil,
	img = nil,
}

local function preview_with_snacks(png)
	local ok, image = pcall(require, "image")
	if not ok then
		notify("image.nvim enabled is required for split previews", vim.log.levels.ERROR)
		return
	end

	if not preview_state.win or not vim.api.nvim_win_is_valid(preview_state.win) then
		-- Create a new vertical split with an empty buffer
		vim.cmd("rightbelow vnew")

		preview_state.buf = vim.api.nvim_get_current_buf()
		preview_state.win = vim.api.nvim_get_current_win()
		vim.bo[preview_state.buf].buftype = "nofile"
		vim.bo[preview_state.buf].bufhidden = "wipe"
		vim.bo[preview_state.buf].swapfile = false
		vim.bo[preview_state.buf].modifiable = false
		vim.api.nvim_buf_set_name(preview_state.buf, "PlantUML Preview")
	end

	-- Remove previous image
	if preview_state.img then
		preview_state.img:clear()
		preview_state.img = nil
	end

	-- Render image in this buffer/window
	preview_state.img = image.from_file(png, {
		window = preview_state.win,
		buffer = preview_state.buf,
		with_virtual_padding = true,
	})
	if not preview_state.img then
		notify("Failed to load image: " .. png, vim.log.levels.ERROR)
		return
	end

	preview_state.img:render()
end

local function preview(png)
	if config.preview_mode == "external" then
		vim.system({ config.viewer, png })
		return
	end
	preview_with_snacks(png)
end

function M.preview()
	if not isPumlFile() then
		notify("Only .puml files are supported", vim.log.levels.ERROR)
		return
	end

	render(preview)
	if config.auto_refresh then
		local bufnr = vim.api.nvim_get_current_buf()
		local group = vim.api.nvim_create_augroup("PlantUMLPreview" .. bufnr, { clear = true })
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = group,
			buffer = bufnr,
			callback = function()
				render(preview)
			end,
		})
	end
end

--- @param type string
M.export = function(type)
	if not isPumlFile() then
		notify("Only `.puml` file is supportet for now", vim.log.levels.ERROR)
		return
	end

	if not vim.fn.executable("plantuml") then
		notify("Plantuml is not installed or not in the Path", vim.log.levels.ERROR)
		return
	end

	if type ~= "png" and type ~= "svg" then
		notify("Unsupported export format: " .. type, vim.log.levels.ERROR)
		return
	end

	vim.system({ "plantuml", "-t" .. type, vim.api.nvim_buf_get_name(0) }, { text = true }, function(result)
		if result.code ~= 0 then
			vim.schedule(function()
				notify(result.stderr ~= "" and result.stderr or "PlantUML export failed", vim.log.levels.ERROR)
			end)
		end
	end)
end

return M
