local M = {}

--- @class PlantumlOpts
--- @field output_dir string
--- @field viewer string
--- @field auto_refresh boolean
--- @field preview_mode string

local config = require("plantuml.config")

--- comment
--- @param opts PlantumlOpts
M.setup = function(opts)
	config.output_dir = opts.output_dir or config.output_dir
	config.viewer = opts.viewer or config.viewer
	config.auto_refresh = opts.auto_refresh or config.auto_refresh
	config.preview_mode = opts.preview_mode or config.preview_mode
end

return M
