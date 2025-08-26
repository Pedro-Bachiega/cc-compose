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
  local instance = Component:new("Column", props)
  setmetatable(instance, self)
  instance.verticalArrangement = props.verticalArrangement
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

  if not modifier.properties.fillMaxWidth or not modifier.properties.fillMaxHeight then
    local maxChildWidth = 0
    local totalChildrenHeight = 0
    for _, child in ipairs(self.children) do
      maxChildWidth = math.max(maxChildWidth, child.width or 0)
      totalChildrenHeight = totalChildrenHeight + (child.height or 1)
    end

    if not modifier.properties.fillMaxHeight then
      if self.verticalArrangement == self.props._compose.Arrangement.SpacedBy and #self.children > 0 then
        totalChildrenHeight = totalChildrenHeight + ((self.props.spacing or 0) * (#self.children - 1))
      end
      self.height = totalChildrenHeight + padding.top + padding.bottom + (border.width * 2)
    end
    if not modifier.properties.fillMaxWidth then
      self.width = maxChildWidth + padding.left + padding.right + (border.width * 2)
    end
  end

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

  -- Cap innerWidth and innerHeight to available space
  innerWidth = math.min(innerWidth, availableWidth - (padding.left + padding.right + (border.width * 2)))
  innerHeight = math.min(innerHeight, availableHeight - (padding.top + padding.bottom + (border.width * 2)))

  -- Ensure innerWidth and innerHeight are not negative
  innerWidth = math.max(0, innerWidth)
  innerHeight = math.max(0, innerHeight)

  local totalUnweightedHeight = 0
  local totalWeight = 0
  local weightedChildren = {}

  -- First pass: Calculate total unweighted height and total weight
  for _, child in ipairs(self.children) do
    local childModifier = child.modifier or {properties = {}}
    if childModifier.properties.weight then
      totalWeight = totalWeight + childModifier.properties.weight
      table.insert(weightedChildren, child)
    else
      totalUnweightedHeight = totalUnweightedHeight + (child.height or 1)
    end
  end

  local remainingHeight = innerHeight - totalUnweightedHeight
  local distributedWeightedHeight = 0

  -- Second pass: Distribute height for weighted children
  for _, child in ipairs(weightedChildren) do
    local childModifier = child.modifier or {properties = {}}
    local weight = childModifier.properties.weight
    if totalWeight > 0 then
      local calculatedHeight = math.floor((weight / totalWeight) * remainingHeight)
      child.height = calculatedHeight -- Assign calculated height to child
      distributedWeightedHeight = distributedWeightedHeight + calculatedHeight
    end
  end

  -- Adjust remainingHeight for any rounding errors in distributedWeightedHeight
  remainingHeight = remainingHeight - distributedWeightedHeight

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
    local mod = child.modifier and child.modifier.properties or {}

    local childWidth = child.width or 0
    if mod.width then
      childWidth = mod.width
    elseif mod.fillMaxWidth then
      childWidth = innerWidth
    end

    local childHeight = child.height or 1
    if mod.height then
      childHeight = mod.height
    elseif mod.fillMaxHeight then
      childHeight = innerHeight
    elseif mod.weight then
      childHeight = child.height -- already calculated
    end

    local childX = innerX
    if self.horizontalAlignment == self.props._compose.HorizontalAlignment.Center then
      childX = innerX + math.floor((innerWidth - childWidth) / 2)
    elseif self.horizontalAlignment == self.props._compose.HorizontalAlignment.End then
      childX = innerX + (innerWidth - childWidth)
    end

    -- Ensure childX does not cause overflow to the right
    childX = math.min(childX, innerX + innerWidth - childWidth)
    -- Ensure childX is not less than innerX (left boundary)
    childX = math.max(childX, innerX)

    if child.draw then
      local childEffects = child:draw(childX, currentY, monitor, childWidth, childHeight)
      for _, effect in ipairs(childEffects) do
        table.insert(launchedEffects, effect)
      end
    end

    local gap = spacing
    if self.verticalArrangement == self.props._compose.Arrangement.SpacedBy or self.verticalArrangement == self.props._compose.Arrangement.SpaceBetween then
      if i == #self.children then
        gap = 0
      end
    end
    currentY = currentY + childHeight + gap
  end

  if effectiveBackground then
    monitor.setBackgroundColor(originalBackground)
  end

  if self.onDrawn then
    self:onDrawn()
  end

  if self.onLaunched then
    table.insert(launchedEffects, self.onLaunched)
  end

  return launchedEffects
end

--- Returns the size of the component.
--- @return table A table containing the width and height of the component.
function Column:getSize()
  return { width = self.width, height = self.height }
end

return Column