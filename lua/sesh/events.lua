---@alias Listener fun(...) nil

---@class EventTable
---@field [string] Listener[]
local event_table = {}

---@class Events
---@field listeners EventTable
local Events = {}

Events.__index = Events

---@return Events
function Events.new()
	local self = {
		listeners = {},
	}
	return setmetatable(self, Events)
end

---@param eventName string
---@param listener Listener
function Events:on(eventName, listener)
	if not self.listeners[eventName] then
		self.listeners[eventName] = {}
	end
	table.insert(self.listeners[eventName], listener)
end

---@param eventName string
---@param listener Listener
function Events:off(eventName, listener)
	if self.listeners[eventName] then
		for i, v in ipairs(self.listeners[eventName]) do
			if v == listener then
				table.remove(self.listeners[eventName], i)
			end
		end
	end
end

---@param eventName string
---@param ... any
function Events:emit(eventName, ...)
	if self.listeners[eventName] then
		for _, v in ipairs(self.listeners[eventName]) do
			vim.schedule_wrap(v)(...)
		end
	end
end

local events = Events:new()

return events
