local Component = require("compose.src.core.Component")

--- @class Column : Component
--- A layout component that arranges its children in a vertical sequence.
--- @field verticalArrangement Arrangement The vertical arrangement of the children.
--- @field horizontalAlignment HorizontalAlignment The horizontal alignment of the children.
local Column = Component:new()
Column.__index = Column

--- Creates a new Column instance.
--- @param props table A table of properties for the component.
--- @param props.children Component[] A list of child components.
--- @param props.modifier? Modifier A Modifier instance to apply to the component.
--- @param props.verticalArrangement? Arrangement The vertical arrangement of the children.
--- @param props.horizontalAlignment? HorizontalAlignment The horizontal alignment of the children. Defaults to HorizontalAlignment.Start.
--- @param props.spacing? number The spacing between children when using Arrangement.SpacedBy.
--- @param props._compose table The compose instance, passed internally.
--- @return Column A new Column instance.
function Column:new(props)
  --- @class Column : Component
  local instance = Component:new(props)
  setmetatable(instance, self)
  instance.verticalArrangement = props.verticalArrangement or props._compose.Arrangement.Top -- Explicitly set default to Top
  instance.horizontalAlignment = props.horizontalAlignment or props._compose.HorizontalAlignment.Start

  local maxChildWidth = 0
  local totalChildrenHeight = 0
  for _, child in ipairs(instance.children) do
    maxChildWidth = math.max(maxChildWidth, child.width or 0)
    totalChildrenHeight = totalChildrenHeight + (child.height or 1)
  end

  if instance.verticalArrangement == props._compose.Arrangement.SpacedBy and #instance.children > 0 then
    totalChildrenHeight = totalChildrenHeight + ((props.spacing or 0) * (#instance.children - 1))
  end

  instance.width = maxChildWidth
  instance.height = totalChildrenHeight

  return instance
end

--- Draws the component on the screen.
--- @param x number The x coordinate to draw at.
--- @param y number The y coordinate to draw at.
--- @param monitor table The monitor to draw on.
--- @param availableWidth number The available width for the component.
--- @param availableHeight number The available height for the component.
--- @return table<fun()> The LaunchedEffect callback functions.
function Column:draw(x, y, monitor, availableWidth, availableHeight)
  local launchedEffects = {}
  self.x = x
  self.y = y

  local modifier = self.modifier or {properties = {}}
  local padding = modifier.properties.padding or {left = 0, top = 0, right = 0, bottom = 0}
  local border = modifier.properties.border or {width = 0, color = nil}

  self.width = modifier.properties.fillMaxWidth and availableWidth or self.width
  self.height = modifier.properties.fillMaxHeight and availableHeight or self.height

  local originalBackground = monitor.getBackgroundColor()
  local effectiveBackground = self.backgroundColor or modifier.properties.backgroundColor
  if effectiveBackground then
    monitor.setBackgroundColor(effectiveBackground)
    for row = y, y + self.height - 1 do
      monitor.setCursorPos(x, row)
      monitor.write(string.rep(" ", self.width))
    end
  end

  local innerX = x + padding.left + border.width
  local innerY = y + padding.top + border.width
  local innerWidth = self.width - padding.left - padding.right - (border.width * 2)
  local innerHeight = self.height - padding.top - padding.bottom - (border.width * 2)

  local totalChildrenHeight = 0
  for _, child in ipairs(self.children) do
    totalChildrenHeight = totalChildrenHeight + (child.height or 1)
  end

  local startY = innerY
  local spacing = 0

  if self.verticalArrangement == self.props._compose.Arrangement.SpaceEvenly then
    spacing = math.floor((innerHeight - totalChildrenHeight) / (#self.children + 1))
    startY = innerY + spacing
  elseif self.verticalArrangement == self.props._compose.Arrangement.SpaceBetween then
    if #self.children > 1 then
      spacing = math.floor((innerHeight - totalChildrenHeight) / (#self.children - 1))
    end
  elseif self.verticalArrangement == self.props._compose.Arrangement.SpaceAround then
    if #self.children > 0 then
      spacing = math.floor((innerHeight - totalChildrenHeight) / #self.children)
      startY = innerY + math.floor(spacing / 2)
    end
  elseif self.verticalArrangement == self.props._compose.Arrangement.SpacedBy then
    spacing = self.props.spacing or 0
  end

  local currentY = startY
  for i, child in ipairs(self.children) do
    local childHeight = (child.modifier and child.modifier.properties.fillMaxHeight) and innerHeight or (child.height or innerHeight)
    local childWidth = (child.modifier and child.modifier.properties.fillMaxWidth) and innerWidth or (child.width or innerWidth)

    local childX = innerX
    if self.horizontalAlignment == self.props._compose.HorizontalAlignment.Center then
      childX = innerX + math.floor((innerWidth - childWidth) / 2)
    elseif self.horizontalAlignment == self.props._compose.HorizontalAlignment.End then
      childX = innerX + (innerWidth - childWidth)
    end

    if child.draw then
      local childEffects = child:draw(childX, currentY, monitor, childWidth, childHeight)
      for _, effect in ipairs(childEffects) do
        table.insert(launchedEffects, effect)
      end
    end

    currentY = currentY + childHeight + spacing
  end

  if effectiveBackground then
    monitor.setBackgroundColor(originalBackground)
  end

  return launchedEffects
end

--- Returns the size of the component.
--- @return table A table containing the width and height of the component.
function Column:getSize()
  return { width = self.width, height = self.height }
end

return Column