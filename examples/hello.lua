-- Load the compose library
-- The 'compose' folder should be in the same directory as this file.
local compose = require("compose.src.compose")

-- Find the main monitor to draw on. This is a standard CC: Tweaked function.
local monitor = peripheral.find("monitor") or error("No monitor found", 0)

-- Get monitor size to display it in the UI.
local monitorWidth, monitorHeight = monitor.getSize()

-- Define a piece of state. `compose.remember` creates a state object that, when its
-- value is changed with `:set()`, will automatically trigger a UI recomposition (redraw).
local counter = compose.remember(0, "counter")

-- Define the root composable function. This function returns a tree of components
-- that represents the UI. It will be re-run every time a state it uses changes.
local function AppComposable()

  -- The root component is a Column that fills the entire screen.
  -- The `fillMaxSize` modifier makes the component expand to the maximum available space given by its parent.
  -- The `background` modifier sets the background color.
  return compose.Column({
    -- `horizontalAlignment` positions the children of the column along the horizontal axis.
    horizontalAlignment = compose.HorizontalAlignment.Center,
    modifier = compose.Modifier:new():fillMaxSize():background(colors.gray)
  }, {
    -- Each item inside the `{}` is a child of the Column.

    compose.Text({text = "Monitor Size: " .. monitorWidth .. "x" .. monitorHeight}),
    compose.Text({text = " "}), -- An empty Text component is used as a simple spacer.

    -- This Text component demonstrates filling the maximum width and having its own background.
    compose.Text({
      text = "Welcome to Compose for CC: Tweaked!",
      textColor = colors.orange,
      modifier = compose.Modifier:new():fillMaxWidth():background(colors.black)
    }),
    compose.Text({text = " "}),

    -- This Text component displays the current value of the `counter` state variable.
    -- When `counter` changes, this component will be redrawn with the new value.
    compose.Text({text = "Counter: " .. counter:get(), textColor = colors.lightBlue}),
    compose.Text({text = " "}),

    -- DEMONSTRATION OF HORIZONTAL ARRANGEMENTS IN A ROW

    -- 1. Arrangement.SpaceBetween
    -- Places children with the first at the start and the last at the end,
    -- with the remaining space distributed evenly between them.
    compose.Text({text = "Arrangement.SpaceBetween"}),
    compose.Row({
      horizontalArrangement = compose.Arrangement.SpaceBetween,
      verticalAlignment = compose.VerticalAlignment.Center, -- Center children vertically.
      modifier = compose.Modifier:new():fillMaxWidth():background(colors.blue)
    }, {
      compose.Button({text = "Increment", onClick = function() counter:set(counter:get() + 1) end, modifier = compose.Modifier:new():background(colors.green)}),
      compose.Button({text = "Decrement", onClick = function() counter:set(counter:get() - 1) end, modifier = compose.Modifier:new():background(colors.red)})
    }),
    compose.Text({text = " "}),

    -- 2. Arrangement.SpaceAround
    -- Places children such that they are spaced evenly, with half of the space
    -- before the first child and after the last child.
    compose.Text({text = "Arrangement.SpaceAround"}),
    compose.Row({
      horizontalArrangement = compose.Arrangement.SpaceAround,
      modifier = compose.Modifier:new():fillMaxWidth():background(colors.purple)
    }, {
      -- These children also have their own modifiers.
      compose.Text({text = "Left", textColor = colors.yellow, modifier = compose.Modifier:new():fillMaxWidth():background(colors.cyan)}),
      compose.Text({text = "Middle", textColor = colors.yellow, modifier = compose.Modifier:new():fillMaxWidth():background(colors.magenta)}),
      compose.Text({text = "Right", textColor = colors.yellow, modifier = compose.Modifier:new():fillMaxWidth():background(colors.cyan)})
    }),
    compose.Text({text = " "}),

    -- 3. Arrangement.SpacedBy
    -- Places a fixed amount of space between each child.
    compose.Text({text = "Arrangement.SpacedBy"}),
    compose.Row({
      horizontalArrangement = compose.Arrangement.SpacedBy,
      spacing = 2, -- Define the fixed space between children.
      modifier = compose.Modifier:new():fillMaxWidth():background(colors.brown)
    }, {
      -- These children demonstrate filling the maximum height of the parent Row.
      compose.Text({text = "Item1", textColor = colors.white, modifier = compose.Modifier:new():fillMaxHeight():background(colors.red)}),
      compose.Text({text = "Item2", textColor = colors.white, modifier = compose.Modifier:new():fillMaxHeight():background(colors.green)}),
      compose.Text({text = "Item3", textColor = colors.white, modifier = compose.Modifier:new():fillMaxHeight():background(colors.blue)}),
      compose.Text({text = "Item4", textColor = colors.white, modifier = compose.Modifier:new():fillMaxHeight():background(colors.purple)})
    }),

    -- This empty Text with `fillMaxHeight` acts as a flexible spacer.
    -- It will expand to push the component after it (the Exit button) to the bottom.
    compose.Text({text = " ", modifier = compose.Modifier:new():fillMaxHeight()}),

    -- The final component in the root Column.
    compose.Button({text = "Exit", onClick = function() compose.exit() end, modifier = compose.Modifier:new():fillMaxWidth():background(colors.black), textColor = colors.white})
  })
end

-- This is the entry point. It tells the compose framework to start the rendering
-- and event loop, using our AppComposable function as the root of the UI tree.
compose.render(AppComposable, monitor)
