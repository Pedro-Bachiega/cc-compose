local State = {}
State.__index = State

local statesFile = "states.dat"
local allPersistentStates = {} -- Global table to hold references to persistent State objects

local function saveAllPersistentStates()
    local dataToSave = {}
    for tag, stateInstance in pairs(allPersistentStates) do
        dataToSave[tag] = stateInstance:get() -- Get the current value
    end
    local file = fs.open(statesFile, "w")
    if file then
        file.write(textutils.serialize(dataToSave))
        file.close()
    else
        print("Error: Could not save persistent states to " .. statesFile)
    end
end

local function loadAllPersistentStates()
    local file = fs.open(statesFile, "r")
    if file then
        local content = file.readAll()
        file.close()
        local loadedData = textutils.unserialize(content) or {}
        return loadedData
    else
        print("No persistent states file found. Starting fresh.")
        return {}
    end
end

local loadedPersistentData = loadAllPersistentStates() -- Load once on script start

--- Performs a deep comparison of two tables.
--- @param t1 table The first table.
--- @param t2 table The second table.
--- @return boolean True if the tables are equal, false otherwise.
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

--- Creates a new State instance.
--- @param initialValue any The initial value of the state.
--- @param tag string A tag for debugging purposes.
--- @param persist boolean Whether to persist the state across reboots.
--- @return table A new State instance.
function State:new(initialValue, tag, persist)
  local instance = setmetatable({}, self)
  instance._tag = tag
  instance._value = initialValue
  instance._listeners = {}
  instance._persist = persist or false

  if instance._persist and instance._tag then
    -- If a value for this tag was loaded, use it
    if loadedPersistentData[instance._tag] ~= nil then
      instance._value = loadedPersistentData[instance._tag]
    end
    allPersistentStates[instance._tag] = instance -- Register for saving
  end

  return instance
end

--- Gets the value of the state.
--- @param transformFn function An optional function to transform the value before returning.
--- @return any The value of the state.
function State:get(transformFn)
  if transformFn and type(transformFn) == "function" then
    return transformFn(self._value)
  end
  return self._value
end

--- Sets the value of the state.
--- If the new value is different from the current value, it will notify listeners and schedule a re-composition.
--- @param newValue any The new value to set.
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

  if self._persist and self._tag then
    saveAllPersistentStates() -- Save all persistent states
  end
end

--- Adds a listener to the state.
--- @param listener function The listener to add.
function State:addListener(listener)
  table.insert(self._listeners, listener)
end

--- Removes a listener from the state.
--- @param listener function The listener to remove.
function State:removeListener(listener)
  for i, l in ipairs(self._listeners) do
    if l == listener then
      table.remove(self._listeners, i)
      return
    end
  end
end

--- Notifies all listeners of a change in the state.
function State:notifyListeners()
  for _, listener in ipairs(self._listeners) do
    listener(self._value)
  end
end

return State