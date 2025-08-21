-- src/core/State.lua
local State = {}
State.__index = State

-- Helper function for deep table comparison
local function deepEqual(t1, t2)
  if type(t1) ~= "table" or type(t2) ~= "table" then return t1 == t2 end

  if #t1 ~= #t2 then return false end

  for k, v in pairs(t1) do
    if not deepEqual(v, t2[k]) then return false end
  end

  for k, v in pairs(t2) do
    if t1[k] == nil then return false end
  end

  return true
end

function State:new(initialValue, tag)
  local instance = setmetatable({}, self)
  instance._tag = tag
  instance._value = initialValue
  instance._listeners = {}
  return instance
end

function State:get()
  return self._value
end

function State:set(newValue)
  if type(self._value) == "table" and type(newValue) == "table" then
    if deepEqual(self._value, newValue) then return end
  else
    if self._value == newValue then return end
  end

  print("State " .. (self._tag and "'" .. self._tag .. "' " or "") .. "changed, scheduling re-composition...")
  self._value = newValue
  self:notifyListeners()
  _G._currentAppInstance:scheduleRecomposition()
end

function State:addListener(listener)
  table.insert(instance._listeners, listener)
end

function State:removeListener(listener)
  for i, l in ipairs(self._listeners) do
    if l == listener then
      table.remove(self._listeners, i)
      return
    end
  end
end

function State:notifyListeners()
  for _, listener in ipairs(self._listeners) do
    listener(self._value)
  end
end

return State
