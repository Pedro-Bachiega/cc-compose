local Column = require("compose.src.components.Column")
local Row = require("compose.src.components.Row")
local Text = require("compose.src.components.Text")
local Button = require("compose.src.components.Button")
local State = require("compose.src.core.State")
local App = require("compose.src.core.App")
local Modifier = require("compose.src.core.Modifier")

local compose = {}

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

compose.Modifier = Modifier

--- Creates a new Column component.
--- @param props table A table of properties for the component.
--- @param children table A table of child components.
--- @return table A new Column component.
function compose.Column(props, children)
  props = props or {}
  props.children = children or {}
  props._compose = compose
  return Column:new(props)
end

--- Creates a new Row component.
--- @param props table A table of properties for the component.
--- @param children table A table of child components.
--- @return table A new Row component.
function compose.Row(props, children)
  props = props or {}
  props.children = children or {}
  props._compose = compose
  return Row:new(props)
end

--- Creates a new Text component.
--- @param props table A table of properties for the component.
--- @return table A new Text component.
function compose.Text(props)
  return Text:new(props)
end

--- Creates a new Button component.
--- @param props table A table of properties for the component.
--- @return table A new Button component.
function compose.Button(props)
  return Button:new(props)
end

--- Exits the application.
function compose.exit()
  local instance = _G._currentAppInstance
  if not instance then return end

  local monitor = instance.monitor
  monitor.clear()
  monitor.setCursorPos(1, 1)
  instance.running = false
end

--- Creates a new State instance.
--- @param initialValue any The initial value of the state.
--- @param tag string A tag for debugging purposes.
--- @return table A new State instance.
function compose.remember(initialValue, tag)
  return State:new(initialValue, tag)
end

--- Renders the application.
--- @param rootComposable function The root composable function of the application.
--- @param monitor table The monitor to render to.
function compose.render(rootComposable, monitor)
  local app = App:new(rootComposable)
  app:render(monitor)
end

return compose