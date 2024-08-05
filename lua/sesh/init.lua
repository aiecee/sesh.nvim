local events = require("sesh.events")
local base64 = require("sesh.base64")
local build_config = require("sesh.config")

local H = {}

function H.get_file_name()
	local cwd = vim.fn.getcwd()
	local encoded_cwd = base64.encode(cwd)
	return encoded_cwd .. ".vim"
end

function H.log_info(msg)
	vim.notify(msg, vim.log.levels.INFO)
end

function H.log_warn(msg)
	vim.notify(msg, vim.log.levels.WARN)
end

function H.log_error(msg)
	vim.notify(msg, vim.log.levels.ERROR)
end

local M = {}
---@type integer
local _autocmd_id
---@type string?
local _file
---@type SeshConfig
local config
---@type boolean
local _active = false

---@param partial_config PartialSeshConfig?
function M.setup(partial_config)
	config = build_config(partial_config)
	vim.fn.mkdir(config.dir, "p")
end

---@param event "LoadPre" | "LoadPost" | "SavePre" | "SavePost"
---@param callback Listener
function M.hook(event, callback)
	events:on(event, callback)
end

function M.save()
	if _autocmd_id == -1 or not _file then
		H.log_error("Sesh: A session has to be started in order to save")
		H.log_error(_autocmd_id)
		H.log_error(_file)
		return
	end

	events:emit("SavePre")
	vim.cmd("mks! " .. vim.fs.joinpath(config.dir, _file))
	events:emit("SavePost")
end

---@param session_file string? Session file to load located in the configured directory
function M.load(session_file)
	local file = vim.fs.joinpath(config.dir, session_file or H.get_file_name())

	if vim.fn.filereadable(file) ~= 0 then
		events:emit("LoadPre")
		vim.cmd("silent! source " .. file)
		events:emit("LoadPost")
	else
		H.log_error("Sesh: Unable to open session for file: ")
	end
end

---@param file string?
function M.start(file)
	if _active then
		H.log_warn("Sesh: A session has already been started")
		return
	end

	_file = file or H.get_file_name()

	local group = vim.api.nvim_create_augroup("Sesh", { clear = true })
	_autocmd_id = vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			M.save()
		end,
	})

	_active = true
end

function M.stop()
	if not _active then
		H.log_error("Sesh: A session has not been started")
		return
	end

	vim.api.nvim_del_augroup_by_id(_autocmd_id)
	_autocmd_id = -1
	_file = nil
	_active = false
end

function M.list()
	return vim.fn.glob(vim.fs.joinpath(config.dir, "*.vim"), true, true)
end

return M
