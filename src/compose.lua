local Button = require("compose.src.components.Button")
local Column = require("compose.src.components.Column")
local ProgressBar = require("compose.src.components.ProgressBar")
local Row = require("compose.src.components.Row")
local Text = require("compose.src.components.Text")

local App = require("compose.src.core.App")
local Modifier = require("compose.src.core.Modifier")
local State = require("compose.src.core.State")

--- @class compose
--- The main entry point for the Compose framework.
--- Provides factory functions for creating components and managing the application lifecycle.
local compose = {}

--- @enum HorizontalAlignment
--- Specifies the horizontal alignment of components within a container.
compose.HorizontalAlignment = {
  Start = "start",
  Center = "center",
  End = "end"
}

--- @enum VerticalAlignment
--- Specifies the vertical alignment of components within a container.
compose.VerticalAlignment = {
  Top = "top",
  Center = "center",
  Bottom = "bottom"
}

--- @enum Arrangement
--- Specifies the arrangement of components within a layout.
compose.Arrangement = {
  SpaceEvenly = "spaceEvenly",
  SpaceBetween = "spaceBetween",
  SpaceAround = "spaceAround",
  SpacedBy = "spacedBy"
}

--- The Modifier class.
--- @type Modifier
compose.Modifier = Modifier

--- Creates a new Column component.
--- @param props table A table of properties for the component.
--- @param children Component[] A table of child components.
--- @return Column A new Column component.
function compose.Column(props, children)
  props = props or {}
  props.children = children or {}
  props._compose = compose
  return Column:new(props)
end

--- Creates a new Row component.
--- @param props table A table of properties for the component.
--- @param children Component[] A table of child components.
--- @return Row A new Row component.
function compose.Row(props, children)
  props = props or {}
  props.children = children or {}
  props._compose = compose
  return Row:new(props)
end

--- Creates a new Text component.
--- @param props table A table of properties for the component.
--- @return Text A new Text component.
function compose.Text(props)
  return Text:new(props)
end

--- Creates a new Button component.
--- @param props table A table of properties for the component.
--- @return Button A new Button component.
function compose.Button(props)
  return Button:new(props)
end

--- Creates a new ProgressBar component.
--- @param props table A table of properties for the component.
--- @return ProgressBar A new ProgressBar component.
function compose.ProgressBar(props)
  return ProgressBar:new(props)
end

--- Exits the currently running Compose application.
function compose.exit()
  local instance = _G._currentAppInstance
  if not instance then return end

  local monitor = instance.monitor
  monitor.clear()
  monitor.setCursorPos(1, 1)
  instance.running = false
end

--- Creates a new State instance that can be remembered across re-compositions.
--- @param initialValue any The initial value of the state.
--- @param tag? string A unique tag for debugging and persistence.
--- @param persist? boolean Whether to persist the state across reboots. Defaults to false.
--- @return State A new State instance.
function compose.remember(initialValue, tag, persist)
  return State:new(initialValue, tag, persist)
end

--- Renders the application on the specified monitor.
--- @param rootComposable fun():Component The root composable function of the application.
--- @param monitor table The monitor peripheral to render to.
function compose.render(rootComposable, monitor)
  local app = App:new(rootComposable)
  app:render(monitor)
end

return compose