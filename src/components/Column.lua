local Component = require("compose.src.core.Component")

local Column = Component:new()
Column.__index = Column

function Column:new(props)
  local instance = Component:new(props)
  setmetatable(instance, self)
  instance.verticalArrangement = props.verticalArrangement or props._compose.Arrangement.Top
  instance.horizontalAlignment = props.horizontalAlignment or props._compose.HorizontalAlignment.Start

  -- Intrinsic size calculation
  local maxChildWidth = 0
  local totalChildrenHeight = 0
  for _, child in ipairs(instance.children) do
    maxChildWidth = math.max(maxChildWidth, child.width or 0)
    totalChildrenHeight = totalChildrenHeight + (child.height or 1)
  end

  instance.width = maxChildWidth
  instance.height = totalChildrenHeight

  return instance
end

function Column:draw(x, y, monitor, availableWidth, availableHeight)
  self.x = x
  self.y = y

  local modifier = self.modifier or {properties = {}}
  local padding = modifier.properties.padding or {left = 0, top = 0, right = 0, bottom = 0}
  local border = modifier.properties.border or {width = 0, color = nil}

  -- Determine the size of this Column
  self.width = modifier.properties.fillMaxWidth and availableWidth or 0
  self.height = modifier.properties.fillMaxHeight and availableHeight or 0

  -- If not filling max size, calculate size based on children (intrinsic size)
  if not modifier.properties.fillMaxWidth or not modifier.properties.fillMaxHeight then
    local maxChildWidth = 0
    local totalChildrenHeight = 0
    for _, child in ipairs(self.children) do
      maxChildWidth = math.max(maxChildWidth, child.width or 0)
      totalChildrenHeight = totalChildrenHeight + (child.height or 0)
    end
    if not modifier.properties.fillMaxWidth then
      self.width = maxChildWidth + padding.left + padding.right + (border.width * 2)
    end
    if not modifier.properties.fillMaxHeight then
      self.height = totalChildrenHeight + padding.top + padding.bottom + (border.width * 2)
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

  local nonFillHeight = 0
  local fillCount = 0
  for _, child in ipairs(self.children) do
    if child.modifier and child.modifier.properties.fillMaxHeight then
      fillCount = fillCount + 1
    else
      nonFillHeight = nonFillHeight + (child.height or 1)
    end
  end

  local fillHeight = 0
  if fillCount > 0 then
    fillHeight = math.floor((innerHeight - nonFillHeight) / fillCount)
  end

  local currentY = innerY
  for _, child in ipairs(self.children) do
    local childHeight = (child.modifier and child.modifier.properties.fillMaxHeight) and fillHeight or (child.height or 1)
    local childWidth = (child.modifier and child.modifier.properties.fillMaxWidth) and innerWidth or (child.width or innerWidth)

    local childX = innerX
    if self.horizontalAlignment == self.props._compose.HorizontalAlignment.Center then
      childX = innerX + math.floor((innerWidth - childWidth) / 2)
    elseif self.horizontalAlignment == self.props._compose.HorizontalAlignment.End then
      childX = innerX + (innerWidth - childWidth)
    end

    if child.draw then
      child:draw(childX, currentY, monitor, childWidth, childHeight)
    end
    currentY = currentY + childHeight
  end

  -- Restore original background color AFTER children have been drawn
  if effectiveBackground then
    monitor.setBackgroundColor(originalBackground)
  end

  if self.onDrawn then
    self:onDrawn(self)
  end
end

function Column:getSize()
  return { width = self.width, height = self.height }
end

return Column
