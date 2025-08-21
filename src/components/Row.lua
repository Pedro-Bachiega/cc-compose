local Component = require("compose.src.core.Component")

local Row = Component:new()
Row.__index = Row

function Row:new(props)
  local instance = Component:new(props)
  setmetatable(instance, self)
  instance.horizontalArrangement = props.horizontalArrangement or props._compose.Arrangement.Start
  instance.verticalAlignment = props.verticalAlignment or props._compose.VerticalAlignment.Top

  -- Intrinsic size calculation
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

function Row:draw(x, y, monitor, availableWidth, availableHeight)
  self.x = x
  self.y = y

  local modifier = self.modifier or {properties = {}}
  local padding = modifier.properties.padding or {left = 0, top = 0, right = 0, bottom = 0}
  local border = modifier.properties.border or {width = 0, color = nil}

  -- Determine the size of this Row
  self.width = modifier.properties.fillMaxWidth and availableWidth or 0
  self.height = modifier.properties.fillMaxHeight and availableHeight or 0

  -- If not filling max size, calculate size based on children (intrinsic size)
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

  -- Draw background and border
  local originalBackground = monitor.getBackgroundColor()
  local effectiveBackground = self.backgroundColor or modifier.properties.backgroundColor
  if effectiveBackground then
    monitor.setBackgroundColor(effectiveBackground)
    for row = y, y + self.height - 1 do
      monitor.setCursorPos(x, row)
      monitor.write(string.rep(" ", self.width))
    end
  end

  -- Layout and draw children
  local innerX = x + padding.left + border.width
  local innerY = y + padding.top + border.width
  local innerWidth = self.width - padding.left - padding.right - (border.width * 2)
  local innerHeight = self.height - padding.top - padding.bottom - (border.width * 2)

  -- 1. Pre-calculate child widths and total width
  local nonFillWidth = 0
  local fillCount = 0
  for _, child in ipairs(self.children) do
    if child.modifier and child.modifier.properties.fillMaxWidth then
      fillCount = fillCount + 1
    else
      nonFillWidth = nonFillWidth + (child.width or 0)
    end
  end

  local fillWidth = 0
  if fillCount > 0 then
    local spacing = (self.horizontalArrangement == self.props._compose.Arrangement.SpacedBy and self.props.spacing * (#self.children - 1)) or 0
    fillWidth = math.floor((innerWidth - nonFillWidth - spacing) / fillCount)
  end

  local totalChildrenWidth = 0
  for _, child in ipairs(self.children) do
    local childWidth = (child.modifier and child.modifier.properties.fillMaxWidth) and fillWidth or (child.width or 0)
    totalChildrenWidth = totalChildrenWidth + childWidth
  end

  -- 2. Calculate spacing based on arrangement
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

  -- 3. Draw children with correct spacing
  local currentX = innerX + startOffset
  for i, child in ipairs(self.children) do
    local childWidth = (child.modifier and child.modifier.properties.fillMaxWidth) and fillWidth or (child.width or 0)
    local childHeight = (child.modifier and child.modifier.properties.fillMaxHeight) and innerHeight or (child.height or innerHeight)

    local childY = innerY
    if self.verticalAlignment == self.props._compose.VerticalAlignment.Center then
      childY = innerY + math.floor((innerHeight - childHeight) / 2)
    elseif self.verticalAlignment == self.props._compose.VerticalAlignment.Bottom then
      childY = innerY + (innerHeight - childHeight)
    end

    if child.draw then
      child:draw(currentX, childY, monitor, childWidth, childHeight)
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

  -- Restore original background color AFTER children have been drawn
  if effectiveBackground then
    monitor.setBackgroundColor(originalBackground)
  end

  if self.onDrawn then
    self:onDrawn(self)
  end
end

function Row:getSize()
  return { width = self.width, height = self.height }
end

return Row
