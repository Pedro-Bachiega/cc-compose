--- @class Component
--- The base class for all UI components in the Compose framework.
--- @field props table The properties passed to the component.
--- @field children Component[] A list of child components.
--- @field x number The x-coordinate of the component's top-left corner.
--- @field y number The y-coordinate of the component's top-left corner.
--- @field width number The width of the component.
--- @field height number The height of the component.
--- @field onDrawn fun(self: Component) A function to call after the component has been drawn.
--- @field backgroundColor? number The background color of the component.
--- @field modifier? Modifier A Modifier instance to apply to the component.
--- @field onClick? fun() A function to call when the component is clicked.
local Component = {}
Component.__index = Component

--- Creates a new Component instance.
--- This is the base class for all components.
--- @param props? table A table of properties for the component.
--- @param props.children? Component[] A list of child components.
--- @param props.onDrawn? fun(self: Component) A function to call after the component has been drawn.
--- @param props.backgroundColor? number The background color of the component.
--- @param props.modifier? Modifier A Modifier instance to apply to the component.
--- @return Component A new Component instance.
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

  -- Transfer onClick from modifier to instance if present
  if instance.modifier and instance.modifier.properties and instance.modifier.properties.onClick then
    instance.onClick = instance.modifier.properties.onClick
  end

  return instance
end

--- A lifecycle method that is called after the component has been drawn.
--- @param instance Component The component instance that was drawn.
function Component:onDrawn(instance)
end

--- Returns the size of the component.
--- @return {width: number, height: number} A table containing the width and height of the component.
function Component:getSize()
  return { width = self.width, height = self.height }
end

return Component