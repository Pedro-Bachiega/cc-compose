-- examples/navigation_drawer_example.lua

local compose = require("compose.src.compose")
local colors = require("compose.src.model.colors")

local monitor = peripheral.find("monitor") or error("No monitor found", 0)
local monitorWidth, monitorHeight = monitor.getSize()

local function AppComposable()
    local isDrawerOpen = compose.remember(false, "isDrawerOpen")

    local function openDrawer()
        isDrawerOpen:set(true)
    end

    local function closeDrawer()
        isDrawerOpen:set(false)
    end

    return compose.NavigationDrawer({
        isOpen = isDrawerOpen,
        onClose = closeDrawer,
        drawerContent = compose.Column({
            modifier = compose.Modifier:new():fillMaxSize():background(colors.blue)
        }, {
            compose.Text({text = "Navigation Menu", textColor = colors.white, textScale = 2}),
            compose.Spacer({props = {height = 1}}),
            compose.Button({
                text = "Item 1",
                onClick = function() print("Item 1 clicked"); closeDrawer() end,
                modifier = compose.Modifier:new():fillMaxWidth():background(colors.darkBlue)
            }),
            compose.Button({
                text = "Item 2",
                onClick = function() print("Item 2 clicked"); closeDrawer() end,
                modifier = compose.Modifier:new():fillMaxWidth():background(colors.darkBlue)
            }),
            compose.Spacer({props = {height = 1}}),
            compose.Button({
                text = "Close Drawer",
                onClick = closeDrawer,
                modifier = compose.Modifier:new():fillMaxWidth():background(colors.red)
            })
        }),
        content = compose.Column({
            modifier = compose.Modifier:new():fillMaxSize():background(colors.gray),
            horizontalAlignment = compose.HorizontalAlignment.Center,
            verticalArrangement = compose.Arrangement.Center
        }, {
            compose.Text({text = "Main Content Area", textColor = colors.white, textScale = 2}),
            compose.Spacer({props = {height = 2}}),
            compose.Button({
                text = "Open Drawer",
                onClick = openDrawer,
                modifier = compose.Modifier:new():background(colors.green)
            }),
            compose.Spacer({props = {height = 2}}),
            compose.Text({text = "Click outside the drawer to close it.", textColor = colors.lightGray})
        })
    })
end

compose.render(AppComposable, monitor)
