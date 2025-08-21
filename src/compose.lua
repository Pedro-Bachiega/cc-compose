local Column = require("compose.src.components.Column")
local Row = require("compose.src.components.Row")
local Text = require("compose.src.components.Text")
local Button = require("compose.src.components.Button")
local State = require("compose.src.core.State")
local App = require("compose.src.core.App")
local Modifier = require("compose.src.core.Modifier") -- New require

local compose = {}

-- Enums for alignment and arrangement
compose.HorizontalAlignment = {
  Start = "start",
  Center = "center",
  End = "end"
}

compose.VerticalAlignment = {
  Top = "top",
  Center = "center",
  Bottom = "bottom"
}

compose.Arrangement = {
  SpaceEvenly = "spaceEvenly",
  SpaceBetween = "spaceBetween",
  SpaceAround = "spaceAround",
  SpacedBy = "spacedBy"
}

-- Expose Modifier
compose.Modifier = Modifier

function compose.Column(props, children)
  props = props or {}
  props.children = children or {}
  props._compose = compose -- Pass the compose table
  return Column:new(props)
end

function compose.Row(props, children)
  props = props or {}
  props.children = children or {}
  props._compose = compose -- Pass the compose table
  return Row:new(props)
end

function compose.Text(props)
  return Text:new(props)
end

function compose.Button(props)
  return Button:new(props)
end

function compose.exit()
  local instance = _G._currentAppInstance
  if not instance then return end

  local monitor = instance.monitor
  monitor.clear()
  monitor.setCursorPos(1, 1)
  instance.running = false
end

function compose.remember(initialValue, tag)
  return State:new(initialValue, tag)
end

function compose.render(rootComposable, monitor)
  local app = App:new(rootComposable)
  app:render(monitor)
end

return compose
