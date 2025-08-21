local Component = {}
Component.__index = Component

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

-- Default onDrawn handler (does nothing)
function Component:onDrawn(instance)
  -- This can be overridden by individual components
end

function Component:getSize()
  return { width = self.width, height = self.height }
end

return Component
