_G.vim = vim

local icons = {}
local loaded = false
local default_icon = {
	icon = "",
	color = "#6d8086",
	name = "Default",
}
local config = {
	override = {},
	default = false,
	theme = "default",
}

local function set_icons()
	icons = require(string.format("nvim-web-devicons.themes.%s", vim.g.nvim_web_devicons_theme or "default"))
end

-- compatible
-- for get_icons function
set_icons()

local function get_highlight_name(data)
	return data.name and "DevIcon" .. data.name
end

local function set_up_highlights()
	vim.defer_fn(function()
		for _, icon_data in pairs(icons) do
			if icon_data.color and icon_data.name then
				local hl_group = get_highlight_name(icon_data)
				if hl_group then
					vim.cmd("highlight! " .. hl_group .. " guifg=" .. icon_data.color)
				end
			end
		end
	end, 1)
end

local function setup(opts)
	loaded = true

	opts = opts or {}

	if opts.theme then
		vim.g.nvim_web_devicons_theme = opts.theme
	elseif vim.g.nvim_web_devicons_theme then
		opts.theme = vim.g.nvim_web_devicons_theme
	end
	config = vim.tbl_extend("force", config, opts)

	-- theme
	set_icons()

	-- override default icon
	if config.override.default_icon then
		default_icon = config.override.default_icon
	end

	-- override icons
	icons = vim.tbl_extend("force", icons, config.override)

	-- why need this?
	table.insert(icons, default_icon)

	-- icon highlights
	set_up_highlights()
	vim.api.nvim_exec(
		[[
    augroup NvimWebDevicons
    autocmd!
    autocmd ColorScheme * lua require('nvim-web-devicons').set_up_highlights()
    augroup END
  ]],
		false
	)
end

local function get_icon(name, ext, opts)
	if not loaded then
		setup()
	end

	-- name ext default
	local icon_data = icons[name] or icons[ext]

	if not icon_data and ((opts and opts.default) or config.default) then
		icon_data = default_icon
	end

	if icon_data then
		return icon_data.icon, get_highlight_name(icon_data)
	end
end

return {
	get_icon = get_icon,
	setup = setup,
	has_loaded = function()
		return loaded
	end,
	get_icons = function()
		return icons
	end,
	set_up_highlights = set_up_highlights,
}
