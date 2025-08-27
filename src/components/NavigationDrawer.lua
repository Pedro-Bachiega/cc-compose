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
local NavigationDrawer = Component:new("NavigationDrawer", {})
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
    instance.drawerContentWidth = instance.drawerContent.width or 0
    instance.drawerContentHeight = instance.drawerContent.height or 1

    -- Calculate content size
    instance.contentWidth = instance.content.width or 0
    instance.contentHeight = instance.content.height or 1

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

    -- Drawer width is 40% of the available width OR its largest child, whichever is smaller, down to a minimum of 20% of the available width
    local drawerActualWidth = math.min(math.floor(availableWidth * 0.4),
        math.max(self.drawerContentWidth, math.floor(availableWidth * 0.2)))
    -- Ensure drawerActualWidth is at least 1 to avoid division by zero or negative width
    drawerActualWidth = math.max(1, drawerActualWidth)

    local contentActualWidth = availableWidth - drawerActualWidth
    -- Ensure contentActualWidth is at least 1
    contentActualWidth = math.max(1, contentActualWidth)

    if drawerOpen then
        -- Draw drawer content
        local childEffects = self.drawerContent:draw(x, y, monitor, drawerActualWidth, availableHeight)
        for _, effect in ipairs(childEffects) do
            table.insert(launchedEffects, effect)
        end
    end

    local contentActualX = x + drawerActualWidth
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
