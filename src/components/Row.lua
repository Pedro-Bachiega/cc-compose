local Component = require("compose.src.core.Component")

--- @class Row : Component
--- A layout component that arranges its children in a horizontal sequence.
--- @field horizontalArrangement Arrangement The horizontal arrangement of the children.
--- @field verticalAlignment VerticalAlignment The vertical alignment of the children.
local Row = Component:new()
Row.__index = Row

--- Creates a new Row instance.
--- @param props table A table of properties for the component.
--- @param props.children Component[] A list of child components.
--- @param props.modifier? Modifier A Modifier instance to apply to the component.
--- @param props.horizontalArrangement? Arrangement The horizontal arrangement of the children.
--- @param props.verticalAlignment? VerticalAlignment The vertical alignment of the children. Defaults to VerticalAlignment.Top.
--- @param props.spacing? number The spacing between children when using Arrangement.SpacedBy.
--- @param props._compose table The compose instance, passed internally.
--- @return Row A new Row instance.
function Row:new(props)
  --- @class Row : Component
  local instance = Component:new(props)
  setmetatable(instance, self)
  instance.horizontalArrangement = props.horizontalArrangement
  instance.verticalAlignment = props.verticalAlignment or props._compose.VerticalAlignment.Top

  local maxChildHeight = 0
  local totalChildrenWidth = 0
  for _, child in ipairs(instance.children) do
    maxChildHeight = math.max(maxChildHeight, child.height or 1)
    totalChildrenWidth = totalChildrenWidth + (child.width or 0)
  end

  if instance.horizontalArrangement == props._compose.Arrangement.SpacedBy and #instance.children > 1 then
    totalChildrenWidth = totalChildrenWidth + (props.spacing * (#instance.children - 1))
  end

  instance.width = totalChildrenWidth
  instance.height = maxChildHeight

  return instance
end

--- Draws the component on the screen.
--- @param x number The x coordinate to draw at.
--- @param param y number The y coordinate to draw at.
--- @param monitor table The monitor to draw on.
--- @param availableWidth number The available width for the component.
--- @param availableHeight number The available height for the component.
--- @return table<fun()> The LaunchedEffect callback functions.
function Row:draw(x, y, monitor, availableWidth, availableHeight)
  local launchedEffects = {}
  self.x = x
  self.y = y

  local modifier = self.modifier or {properties = {}}
  local padding = modifier.properties.padding or {left = 0, top = 0, right = 0, bottom = 0}
  local border = modifier.properties.border or {width = 0, color = nil}

  self.width = modifier.properties.fillMaxWidth and availableWidth or 0
  self.height = modifier.properties.fillMaxHeight and availableHeight or 0

  if not modifier.properties.fillMaxWidth or not modifier.properties.fillMaxHeight then
    local maxChildHeight = 0
    local totalChildrenWidth = 0
    for _, child in ipairs(self.children) do
      maxChildHeight = math.max(maxChildHeight, child.height or 1)
      totalChildrenWidth = totalChildrenWidth + (child.width or 0)
    end
    if not modifier.properties.fillMaxWidth then
      self.width = totalChildrenWidth + padding.left + padding.right + (border.width * 2)
    end
    if not modifier.properties.fillMaxHeight then
      self.height = maxChildHeight + padding.top + padding.bottom + (border.width * 2)
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

  local totalUnweightedWidth = 0
  local totalWeight = 0
  local weightedChildren = {}

  -- First pass: Calculate total unweighted width and total weight
  for _, child in ipairs(self.children) do
    local childModifier = child.modifier or {properties = {}}
    if childModifier.properties.weight then
      totalWeight = totalWeight + childModifier.properties.weight
      table.insert(weightedChildren, child)
    else
      totalUnweightedWidth = totalUnweightedWidth + (child.width or 0)
    end
  end

  local remainingWidth = innerWidth - totalUnweightedWidth
  local distributedWeightedWidth = 0

  -- Second pass: Distribute width for weighted children
  for _, child in ipairs(weightedChildren) do
    local childModifier = child.modifier or {properties = {}}
    local weight = childModifier.properties.weight
    if totalWeight > 0 then
      local calculatedWidth = math.floor((weight / totalWeight) * remainingWidth)
      child.width = calculatedWidth -- Assign calculated width to child
      distributedWeightedWidth = distributedWeightedWidth + calculatedWidth
    end
  end

  -- Adjust remainingWidth for any rounding errors in distributedWeightedWidth
  remainingWidth = remainingWidth - distributedWeightedWidth

  local totalChildrenWidth = 0
  for _, child in ipairs(self.children) do
    totalChildrenWidth = totalChildrenWidth + (child.width or 0)
  end

  local remainingSpace = innerWidth - totalChildrenWidth
  local spacePerItem = 0
  local startOffset = 0

  if self.horizontalArrangement == self.props._compose.Arrangement.SpaceEvenly then
    spacePerItem = math.floor(remainingSpace / (#self.children + 1))
    startOffset = spacePerItem
  elseif self.horizontalArrangement == self.props._compose.Arrangement.SpaceBetween then
    spacePerItem = #self.children > 1 and math.floor(remainingSpace / (#self.children - 1)) or 0
  elseif self.horizontalArrangement == self.props._compose.Arrangement.SpaceAround then
    if #self.children > 0 then
      spacePerItem = math.floor(remainingSpace / #self.children)
      startOffset = math.floor(spacePerItem / 2)
    end
  elseif self.horizontalArrangement == self.props._compose.Arrangement.SpacedBy then
    spacePerItem = self.props.spacing or 0
  end

  local currentX = innerX + startOffset
  for i, child in ipairs(self.children) do
    local childWidth = (child.modifier and child.modifier.properties.fillMaxWidth) and innerWidth or (child.width or 0)
    local childHeight = (child.modifier and child.modifier.properties.fillMaxHeight) and innerHeight or (child.height or innerHeight)

    -- If child has weight, its width is already calculated and assigned in the second pass.
    -- So, we should use child.width directly here.
    if child.modifier and child.modifier.properties.weight then
      childWidth = child.width
    end

    local childY = innerY
    if self.verticalAlignment == self.props._compose.VerticalAlignment.Center then
      childY = innerY + math.floor((innerHeight - childHeight) / 2)
    elseif self.verticalAlignment == self.props._compose.VerticalAlignment.Bottom then
      childY = innerY + (innerHeight - childHeight)
    end

    if child.draw then
      local childEffects = child:draw(currentX, childY, monitor, childWidth, childHeight)
      for _, effect in ipairs(childEffects) do
        table.insert(launchedEffects, effect)
      end
    end
    
    local gap = spacePerItem
    if self.horizontalArrangement == self.props._compose.Arrangement.SpaceAround then
    elseif self.horizontalArrangement == self.props._compose.Arrangement.SpaceEvenly then
    else
      if i == #self.children then
        gap = 0
      end
    end
    currentX = currentX + childWidth + gap
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
--- @return {width: number, height: number} A table containing the width and height of the component.
function Row:getSize()
  return { width = self.width, height = self.height }
end

return Row