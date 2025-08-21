local Component = {}
Component.__index = Component

--- Creates a new Component instance.
--- This is the base class for all components.
--- @param props table A table of properties for the component.
--- @return table A new Component instance.
function Component:new(props)
  props = props or {}

  local instance = setmetatable({}, self)
  instance.props = props
  instance.children = {}
  if props.children then
    instance.children = props.children
  end
  instance.x = 0
  instance.y = 0
  instance.width = 0
  instance.height = 0
  instance.onDrawn = props.onDrawn
  instance.backgroundColor = props.backgroundColor
  instance.modifier = props.modifier
  return instance
end

--- A lifecycle method that is called after the component has been drawn.
--- @param instance table The component instance that was drawn.
function Component:onDrawn(instance)
end

--- Returns the size of the component.
--- @return table A table containing the width and height of the component.
function Component:getSize()
  return { width = self.width, height = self.height }
end

return Component