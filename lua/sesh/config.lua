---@class SeshConfig
---@field dir string

---@class PartialSeshConfig
---@field dir string?

---@type SeshConfig
local default_config = {
	---@diagnostic disable-next-line: param-type-mismatch
	dir = vim.fs.joinpath(vim.fn.stdpath("data"), "sesh"),
}

---@param config PartialSeshConfig?
return function(config)
	local final_config = vim.tbl_deep_extend("keep", default_config, config or {})
	print(vim.inspect(final_config))
	return final_config
end
