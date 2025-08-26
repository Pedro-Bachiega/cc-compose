local LifecycleState = require("compose.src.model.LifecycleState")

--- @class App
--- Manages the lifecycle of a Compose application, including rendering and event handling.
--- @field compositionCount number The number of times the UI has been re-composed.
--- @field rootComposable fun():Component The root composable function of the application.
--- @field monitor table The monitor peripheral to render to.
--- @field uiTree Component The root of the component tree.
--- @field running boolean Whether the application is currently running.
--- @field recompositionPending boolean Whether a re-composition has been scheduled.
local App = {}
App.__index = App

--- Creates a new App instance.
--- @param rootComposable fun():Component The root composable function of the application.
--- @return App A new App instance.
function App:new(rootComposable)
  local instance = setmetatable({}, self)
  instance.compositionCount = 0
  instance.rootComposable = rootComposable
  instance.monitor = nil
  instance.uiTree = nil
  instance.running = true
  instance.recompositionPending = false
  instance.lifecycleState = LifecycleState.INITIALIZED
  return instance
end

--- Schedules a re-composition of the UI on the next frame.
function App:scheduleRecomposition()
  self.recompositionPending = true
end

--- Composes the UI tree and draws it to the monitor.
function App:composeAndDraw()
  self.uiTree = self.rootComposable()
  self.monitor.setBackgroundColor(colors.black)
  self.monitor.clear()
  local w, h = self.monitor.getSize()
  local launchedEffects = self.uiTree:draw(1, 1, self.monitor, w, h)
  self.compositionCount = self.compositionCount + 1

  for _, effect in ipairs(launchedEffects) do
    effect()
  end
end

--- Renders the application and starts the main event loop.
--- @param monitor table The monitor peripheral to render to.
function App:render(monitor)
  self.monitor = monitor
  self.lifecycleState = LifecycleState.Created

  _G._currentAppInstance = self

  self:composeAndDraw()
  self.lifecycleState = LifecycleState.Started
  self.lifecycleState = LifecycleState.Resumed

  while self.running do
    if self.recompositionPending then
      self.recompositionPending = false
      self:composeAndDraw()
    end

    local timerId = os.startTimer(0)

    local eventData = {os.pullEvent()}
    local event = eventData[1]

    if event == "timer" and eventData[2] == timerId then
    elseif event == "monitor_touch" then
      local monitorId, x, y = eventData[2], eventData[3], eventData[4]
      if monitorId == peripheral.getName(self.monitor) then
        local clickedComponent = self:findClickedComponent(self.uiTree, x, y)
        if clickedComponent and clickedComponent.onClick then
          clickedComponent:onClick(x, y)
        end
      end
    end
  end

  self.lifecycleState = LifecycleState.Paused
  self.lifecycleState = LifecycleState.Stopped
  self.lifecycleState = LifecycleState.Destroyed
  _G._currentAppInstance = nil
end

--- Checks if a touch point is inside a component's bounding box.
--- @param component Component The component to check.
--- @param touchX number The x coordinate of the touch.
--- @param touchY number The y coordinate of the touch.
--- @return boolean True if the point is inside the component, false otherwise.
function App:isInside(component, touchX, touchY)
  local isInsideHorizontalBounds = touchX >= component.x and touchX < (component.x + component.width)
  local isInsideVerticalBounds = touchY >= component.y and touchY < (component.y + component.height)
  return isInsideHorizontalBounds and isInsideVerticalBounds
end

--- Finds the topmost component that was clicked at a given position.
--- @param component Component The component to search within.
--- @param touchX number The x coordinate of the click.
--- @param touchY number The y coordinate of the click.
--- @return Component|nil The clicked component, or nil if no component was clicked.
function App:findClickedComponent(component, touchX, touchY)
  if not component then return nil end

  local children = component.children or {}

  if self:isInside(component, touchX, touchY) then
    if component.className == "NavigationDrawer" then
      table.insert(children, table.unpack(component.drawerContent))
      table.insert(children, table.unpack(component.content))
    end

    for i = #children, 1, -1 do
      local clickedChild = self:findClickedComponent(children[i], touchX, touchY)
      if clickedChild then return clickedChild end
    end
    if component.onClick then return component end
  end
  return nil
end

return App