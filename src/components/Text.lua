local Component = require("compose.src.core.Component")

--- @class Text : Component
--- A component for displaying text.
--- @field textColor? number The color of the text.
--- @field textScale? number The scale of the text.
--- @field maxLines? number The maximum number of lines to display before truncating or ellipsizing.
--- @field ellipsize? boolean If true, adds "..." to the end of the last line if text overflows maxLines or availableWidth.
local Text = Component:new("Text", {})
Text.__index = Text

local function wrapText(text, availableWidth, textScale)
    local lines = {}
    local charsPerLine = math.floor(availableWidth / textScale)
    if charsPerLine <= 0 then return {""} end -- Handle cases where no chars fit

    local currentText = text
    while #currentText > 0 do
        local line = string.sub(currentText, 1, charsPerLine)
        table.insert(lines, line)
        currentText = string.sub(currentText, charsPerLine + 1)
    end
    return lines
end

--- Creates a new Text instance.
--- @param props table A table of properties for the component.
--- @param props.text? string The text to display.
--- @param props.textColor? number The color of the text.
--- @param props.textScale? number The scale of the text.
--- @param props.maxLines? number The maximum number of lines to display.
--- @param props.ellipsize? boolean If true, adds "..." to the end of the last line if text overflows.
--- @param props.modifier? Modifier A Modifier instance to apply to the component.
--- @return Text A new Text instance.
function Text:new(props)
  --- @class Text : Component
  local instance = Component:new("Text", props)
  setmetatable(instance, self)
  instance.textColor = props.textColor or colors.white
  instance.textScale = props.textScale or 1
  instance.maxLines = props.maxLines
  instance.ellipsize = props.ellipsize

  local textContent = tostring(props.text or "")
  instance.width = #textContent * (instance.textScale or 1)
  instance.height = 1 * (instance.textScale or 1)
  
  return instance
end

--- Draws the component on the screen.
--- @param x number The x coordinate to draw at.
--- @param y number The y coordinate to draw at.
--- @param monitor table The monitor to draw on.
--- @param availableWidth number The available width for the component.
--- @param availableHeight number The available height for the component.
--- @return table<fun()> The LaunchedEffect callback functions.
function Text:draw(x, y, monitor, availableWidth, availableHeight)
  self.x = x
  self.y = y
  local text = self.props.text or ""

  local modifier = self.modifier or {properties = {}}

  self.width = (modifier.properties.fillMaxWidth and availableWidth) or self.width
  self.height = (modifier.properties.fillMaxHeight and availableHeight) or self.height

  local originalBackgroundColor = monitor.getBackgroundColor()
  local originalTextColor = monitor.getTextColor()

  local effectiveBackground = self.backgroundColor or modifier.properties.backgroundColor
  local effectiveTextColor = self.textColor or modifier.properties.textColor

  if effectiveBackground then
    monitor.setBackgroundColor(effectiveBackground)
    for row = y, y + self.height - 1 do
      monitor.setCursorPos(x, row)
      monitor.write(string.rep(" ", self.width))
    end
  end
  
  if effectiveTextColor then
    monitor.setTextColor(effectiveTextColor)
  end

  local effectiveTextScale = self.textScale or 1
  local maxLines = self.maxLines or math.huge -- Default to no max lines
  local ellipsize = self.ellipsize or false

  local wrappedLines = wrapText(text, availableWidth, effectiveTextScale)
  local linesToDraw = {}

  -- Apply maxLines and ellipsize
  for i, line in ipairs(wrappedLines) do
      if i > maxLines then
          break
      end
      table.insert(linesToDraw, line)
  end

  -- Handle ellipsizing
  if ellipsize and #wrappedLines > maxLines then
      local lastLineIndex = #linesToDraw
      if lastLineIndex > 0 then
          local lastLine = linesToDraw[lastLineIndex]
          local ellipsis = "..."
          local charsPerLine = math.floor(availableWidth / effectiveTextScale)
          if #lastLine + #ellipsis > charsPerLine then
              lastLine = string.sub(lastLine, 1, charsPerLine - #ellipsis) .. ellipsis
          else
              lastLine = lastLine .. ellipsis
          end
          linesToDraw[lastLineIndex] = lastLine
      end
  end

  -- Draw lines
  local currentY = y
  for i, line in ipairs(linesToDraw) do
      if currentY >= y + availableHeight then break end -- Don't draw outside availableHeight
      monitor.setCursorPos(x, currentY)
      monitor.write(line)
      currentY = currentY + effectiveTextScale -- Move to next line, considering text scale
  end

  -- Update self.height based on actual drawn lines
  self.height = math.min(availableHeight, #linesToDraw * effectiveTextScale)
  if self.props.modifier and self.props.modifier.properties.fillMaxHeight then
      self.height = availableHeight
  end


  monitor.setBackgroundColor(originalBackgroundColor)
  monitor.setTextColor(originalTextColor)

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
function Text:getSize()
  return { width = self.width, height = self.height }
end

return Text