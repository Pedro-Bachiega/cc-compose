local Modifier = {}
Modifier.__index = Modifier

function Modifier:new()
  local instance = setmetatable({}, self)
  instance.properties = {}
  return instance
end

function Modifier:background(color)
  self.properties.backgroundColor = color
  return self
end

-- Modify padding to accept individual values or a single value
function Modifier:padding(left, top, right, bottom)
  if type(left) == "number" and top == nil then -- Single value for all sides
    self.properties.padding = {left = left, top = left, right = left, bottom = left}
  elseif type(left) == "number" and type(top) == "number" and right == nil then -- Horizontal and Vertical
    self.properties.padding = {left = left, top = top, right = left, bottom = top}
  elseif type(left) == "number" and type(top) == "number" and type(right) == "number" and type(bottom) == "number" then -- All sides
    self.properties.padding = {left = left, top = top, right = right, bottom = bottom}
  else
    -- Default or error handling
    self.properties.padding = {left = 0, top = 0, right = 0, bottom = 0}
  end
  return self
end

-- New textScale function
function Modifier:textScale(scale)
  self.properties.textScale = scale
  return self
end

-- New border function
function Modifier:border(width, color)
  self.properties.border = {width = width, color = color}
  return self
end

function Modifier:fillMaxWidth()
  self.properties.fillMaxWidth = true
  return self
end

function Modifier:fillMaxHeight()
  self.properties.fillMaxHeight = true
  return self
end

function Modifier:fillMaxSize()
  self.properties.fillMaxWidth = true
  self.properties.fillMaxHeight = true
  return self
end

return Modifier
