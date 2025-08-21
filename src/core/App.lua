local App = {}
App.__index = App

function App:new(rootComposable)
  local instance = setmetatable({}, self)
  instance.compositionCount = 0
  instance.rootComposable = rootComposable
  instance.monitor = nil
  instance.uiTree = nil
  instance.running = true
  instance.recompositionPending = false
  return instance
end

function App:scheduleRecomposition()
  self.recompositionPending = true
end

-- Make composeAndDraw a method of App
function App:composeAndDraw()
  self.uiTree = self.rootComposable() -- Re-compose the UI tree
  self.monitor.setBackgroundColor(colors.black)
  self.monitor.clear()
  local w, h = self.monitor.getSize()
  self.uiTree:draw(1, 1, self.monitor, w, h)
  self.compositionCount = self.compositionCount + 1
end

function App:render(monitor)
  self.monitor = monitor
  
  -- Set global reference for compose.remember to access
  _G._currentAppInstance = self 

  -- Initial composition and draw
  self:composeAndDraw() -- Call the method

  -- Event loop
  while self.running do
    if self.recompositionPending then
      self.recompositionPending = false -- Reset flag before drawing
      self:composeAndDraw()
    end

    -- Use a timer to create a non-blocking event pull
    local timerId = os.startTimer(0) -- Fire immediately

    local eventData = {os.pullEvent()}
    local event = eventData[1]

    if event == "timer" and eventData[2] == timerId then
      -- This is our main loop tick, do nothing and let the loop continue
      -- to check the recompositionPending flag.
    elseif event == "monitor_touch" then
      local monitorId, x, y = eventData[2], eventData[3], eventData[4]
      if monitorId == peripheral.getName(self.monitor) then
        local clickedComponent = self:findClickedComponent(self.uiTree, x, y)
        if clickedComponent and clickedComponent.onClick then
          clickedComponent:onClick(x, y)
          -- The onClick might have scheduled a recomposition
        end
      end
    end
  end
  _G._currentAppInstance = nil -- Clear global reference
end

-- Helper function to check if a point is inside a component's bounding box
function App:isInside(component, touchX, touchY)
  return touchX >= component.x and touchX < (component.x + component.width) and
         touchY >= component.y and touchY < (component.y + component.height)
end

-- Recursive function to find the clicked component
function App:findClickedComponent(component, touchX, touchY)
  if not component then return nil end

  if self:isInside(component, touchX, touchY) then
    -- Check children first, as they are drawn on top
    for i = #component.children, 1, -1 do -- Iterate backwards to check top-most children first
      local clickedChild = self:findClickedComponent(component.children[i], touchX, touchY)
      if clickedChild then
        return clickedChild
      end
    end
    -- If no child was clicked, and this component is clickable, return it
    if component.onClick then
      return component
    end
  end
  return nil
end

return App
