local Component = require("compose.src.core.Component")

--- @class Spacer : Component
--- A component for creating empty space. Its size is determined by the modifier applied to it.
local Spacer = Component:new()
Spacer.__index = Spacer

--- Creates a new Spacer instance.
--- @param props table A table of properties for the component.
--- @param props.modifier? Modifier A Modifier instance to apply to the component.
--- @return Spacer A new Spacer instance.
function Spacer:new(props)
  --- @class Spacer : Component
  local instance = Component:new("Spacer", props)
  setmetatable(instance, self)
  
  -- A spacer has no intrinsic size. Its size is determined by its modifier
  -- and calculated by its parent layout component.
  instance.width = 0
  instance.height = 0
  
  return instance
end

--- Draws the component on the screen.
--- A spacer doesn't draw anything, it just occupies the space allocated by its parent.
--- @param x number The x coordinate to draw at.
--- @param y number The y coordinate to draw at.
--- @param monitor table The monitor to draw on.
--- @param availableWidth number The width allocated for the component by its parent.
--- @param availableHeight number The height allocated for the component by its parent.
--- @return table<fun()> The LaunchedEffect callback functions.
function Spacer:draw(x, y, monitor, availableWidth, availableHeight)
  self.x = x
  self.y = y
  self.width = availableWidth
  self.height = availableHeight

  -- A spacer is empty space, so there's nothing to draw.

  if self.onDrawn then
    self:onDrawn()
  end

  if self.onLaunched then
    return {self.onLaunched}
  end

  return {}
end

--- Returns the size of the component.
--- @return {width: number, height: number} A table containing the width and height of the component.
function Spacer:getSize()
  return { width = self.width, height = self.height }
end

return Spacer