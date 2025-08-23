local Component = require("compose.src.core.Component")

--- @class ProgressBar : Component
--- A component that displays a full-screen loading animation with a message.
--- @field text string The text to display below the animation.
--- @field animationIndex number The index of the current animation character.
--- @field brailleChars string[] An array of Braille characters for animation.
local ProgressBar = Component:new()
ProgressBar.__index = ProgressBar

--- Creates a new Loading instance.
--- @param props table A table of properties for the component.
--- @param props.text string The text to display below the animation.
--- @return ProgressBar A new Loading instance.
function ProgressBar:new(props)
  --- @class ProgressBar : Component
  local instance = Component:new(props)
  setmetatable(instance, self)
  -- Braille characters for animation
  instance.brailleChars = {"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}
  instance.animationIndex = 1
  instance.text = props.text
  instance.width = #props.text
  instance.height = 2
  return instance
end

--- Draws the component on the screen.
--- @param x number The x coordinate to draw at.
--- @param y number The y coordinate to draw at.
--- @param monitor table The monitor to draw on.
--- @param availableWidth number The available width for the component.
--- @param availableHeight number The available height for the component.
function ProgressBar:draw(x, y, monitor, availableWidth, availableHeight)
    local text = self.brailleChars[self.animationIndex]

    local textX = x + math.floor((availableWidth - 1) / 2)
    local textY = y + math.floor((availableHeight - 2) / 2)

    monitor.setCursorPos(textX + math.floor((#self.text - 1) / 2), textY)
    monitor.write(text)
    monitor.setCursorPos(textX, textY + 1)
    monitor.write(self.text)

    self.animationIndex = (self.animationIndex % #self.brailleChars) + 1
end

return ProgressBar
