local Component = require("compose.src.core.Component")

--- @class NavigationDrawer : Component
--- A component that provides a sliding navigation drawer.
--- @field drawerContent Component The content to display inside the drawer.
--- @field content Component The main content of the screen.
--- @field isOpen State A state object controlling the open/closed state of the drawer.
--- @field onClose fun() A function to call when the drawer is requested to be closed (e.g., by clicking outside).
--- @field drawerContentWidth number The calculated width of the drawer content.
--- @field drawerContentHeight number The calculated height of the drawer content.
--- @field contentWidth number The calculated width of the main content.
--- @field contentHeight number The calculated height of the main content.
local NavigationDrawer = Component:new()
NavigationDrawer.__index = NavigationDrawer

--- Creates a new NavigationDrawer instance.
--- @param props table A table of properties for the component.
--- @param props.drawerContent Component[] The content to display inside the drawer.
--- @param props.content Component[] The main content of the screen.
--- @param props.isOpen State A state object controlling the open/closed state of the drawer.
--- @param props.onClose fun() A function to call when the drawer is requested to be closed (e.g., by clicking outside).
--- @return NavigationDrawer A new NavigationDrawer instance.
function NavigationDrawer:new(props)
    --- @class NavigationDrawer : Component
    local instance = Component:new("NavigationDrawer", props)
    setmetatable(instance, self)
    instance.drawerContent = props.drawerContent
    instance.content = props.content
    instance.isOpen = props.isOpen -- This should be a state object from compose.remember
    instance.onClose = props.onClose

    if not props.drawerContent then
        error("[NavigationDrawer] drawerContent is required")
    elseif not props.content then
        error("[NavigationDrawer] content is required")
    end

    -- Calculate drawerContent size
    local drawerChildren = type(instance.drawerContent) == "table" and instance.drawerContent or {instance.drawerContent}
    local maxDrawerChildWidth = 0
    local totalDrawerChildrenHeight = 0
    for _, child in ipairs(drawerChildren) do
        maxDrawerChildWidth = math.max(maxDrawerChildWidth, child.width or 0)
        totalDrawerChildrenHeight = totalDrawerChildrenHeight + (child.height or 1)
    end
    instance.drawerContentWidth = maxDrawerChildWidth
    instance.drawerContentHeight = totalDrawerChildrenHeight

    -- Calculate content size
    local contentChildren = type(instance.content) == "table" and instance.content or {instance.content}
    local maxContentChildWidth = 0
    local totalContentChildrenHeight = 0
    for _, child in ipairs(contentChildren) do
        maxContentChildWidth = math.max(maxContentChildWidth, child.width or 0)
        totalContentChildrenHeight = totalContentChildrenHeight + (child.height or 1)
    end
    instance.contentWidth = maxContentChildWidth
    instance.contentHeight = totalContentChildrenHeight

    return instance
end

--- Draws the component on the screen.
--- @param x number The x coordinate to draw at.
--- @param y number The y coordinate to draw at.
--- @param monitor table The monitor to draw on.
--- @param availableWidth number The available width for the component.
--- @param availableHeight number The availableHeight for the component.
--- @return table<fun()> The LaunchedEffect callback functions.
function NavigationDrawer:draw(x, y, monitor, availableWidth, availableHeight)
    local launchedEffects = {}
    self.x = x
    self.y = y
    self.width = availableWidth -- Set width and height for handleInput
    self.height = availableHeight

    -- Calculate drawerWidth based on 40% of availableWidth or drawerContentWidth
    local drawerWidth = math.max(math.floor(availableWidth * 0.4), self.drawerContentWidth or 0)
    local contentX = x
    local contentWidth = availableWidth

    if self.isOpen and self.isOpen:get() then
        -- If drawer is open, draw drawer content first
        local childEffects = self.drawerContent:draw(x, y, monitor, drawerWidth, availableHeight)
        for _, effect in ipairs(childEffects) do
            table.insert(launchedEffects, effect)
        end

        -- Then, adjust content position and width for the main content
        contentX = x + drawerWidth
        contentWidth = availableWidth - drawerWidth
    end

    -- Draw the main content (shifted if drawer is open)
    local childEffects = self.content:draw(contentX, y, monitor, contentWidth, availableHeight)
    for _, effect in ipairs(childEffects) do
        table.insert(launchedEffects, effect)
    end

    -- Handle onDrawn and onLaunched for the NavigationDrawer itself
    if self.onDrawn then
        self:onDrawn()
    end

    if self.onLaunched then
        table.insert(launchedEffects, self.onLaunched)
    end

    return launchedEffects
end

return NavigationDrawer
