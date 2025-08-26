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
    self.width = availableWidth
    self.height = availableHeight

    local drawerOpen = self.isOpen and self.isOpen:get()

    local drawerActualWidth = 0
    local contentActualX = x
    local contentActualWidth = availableWidth

    if drawerOpen then
        -- Drawer takes up 40% of the available width
        drawerActualWidth = math.floor(availableWidth * 0.4)
        -- Ensure drawerActualWidth is at least 1 to avoid division by zero or negative width
        drawerActualWidth = math.max(1, drawerActualWidth)

        -- Draw drawer content
        local childEffects = self.drawerContent:draw(x, y, monitor, drawerActualWidth, availableHeight)
        for _, effect in ipairs(childEffects) do
            table.insert(launchedEffects, effect)
        end

        -- Adjust main content position and width
        contentActualX = x + drawerActualWidth
        contentActualWidth = availableWidth - drawerActualWidth
        -- Ensure contentActualWidth is at least 0
        contentActualWidth = math.max(0, contentActualWidth)
    end

    -- Draw the main content
    local childEffects = self.content:draw(contentActualX, y, monitor, contentActualWidth, availableHeight)
    for _, effect in ipairs(childEffects) do
        table.insert(launchedEffects, effect)
    end

    if self.onDrawn then
        self:onDrawn()
    end

    if self.onLaunched then
        table.insert(launchedEffects, self.onLaunched)
    end

    return launchedEffects
end

return NavigationDrawer
