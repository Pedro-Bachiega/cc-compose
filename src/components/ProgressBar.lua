local Component = require("compose.src.core.Component")

--- @class ProgressBar : Component
--- A component that displays a full-screen loading animation with a message.
--- @field text string The text to display below the animation.
--- @field animationIndex number The index of the current animation character.
--- @field animationFrames table An array of 3x3 matrices for animation.
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
  -- 3x3 matrix frames for animation
  instance.animationFrames = {
    {
      {"*", "*", " "},
      {"*", " ", " "},
      {" ", " ", " "}
    },
    {
      {"*", "*", "*"},
      {" ", " ", " "},
      {" ", " ", " "}
    },
    {
      {" ", "*", "*"},
      {" ", " ", "*"},
      {" ", " ", " "}
    },
    {
      {" ", " ", "*"},
      {" ", " ", "*"},
      {" ", " ", "*"}
    },
    {
      {" ", " ", " "},
      {" ", " ", "*"},
      {" ", "*", "*"}
    },
    {
      {" ", " ", " "},
      {" ", " ", " "},
      {"*", "*", "*"}
    },
    {
      {" ", " ", " "},
      {"*", " ", " "},
      {"*", "*", " "}
    },
    {
      {"*", " ", " "},
      {"*", " ", " "},
      {"*", " ", " "}
    },
  }
  instance.animationIndex = props._compose.remember(1, "animationIndex", true)
  instance.text = props.text
  instance.width = math.max(#props.text, 3)
  instance.height = 4 -- 3 for matrix, 1 for text
  return instance
end

--- Draws the component on the screen.
--- @param x number The x coordinate to draw at.
--- @param y number The y coordinate to draw at.
--- @param monitor table The monitor to draw on.
--- @param availableWidth number The available width for the component.
--- @param availableHeight number The available height for the component.
function ProgressBar:draw(x, y, monitor, availableWidth, availableHeight)
    local frame = self.animationFrames[self.animationIndex:get()]

    local startX = x + math.floor((availableWidth - 3) / 2)
    local startY = y + math.floor((availableHeight - 4) / 2)

    -- Draw the 3x3 matrix
    for r = 1, 3 do
        monitor.setCursorPos(startX, startY + r - 1)
        for c = 1, 3 do
            monitor.write(frame[r][c])
        end
    end

    -- Draw the text below the animation
    local textX = x + math.floor((availableWidth - #self.text) / 2)
    local textY = startY + 3
    monitor.setCursorPos(textX, textY)
    monitor.write(self.text)

    sleep(0.1) -- A shorter sleep for smoother animation
    self.animationIndex:set((self.animationIndex:get() % #self.animationFrames) + 1)
end

return ProgressBar
