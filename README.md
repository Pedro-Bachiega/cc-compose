# Compose for CC: Tweaked

A declarative UI framework for the Minecraft mod [CC: Tweaked](https://tweaked.cc/), heavily inspired by modern UI toolkits like Jetpack Compose and SwiftUI. This framework allows you to build complex, stateful User Interfaces for in-game computers by writing simple, declarative Lua code.

## Features

*   **Declarative UI:** Describe your UI with a nested structure of components. You define *what* the UI should look like based on its current state, and the framework efficiently handles the rendering and updates.
*   **Stateful Management:** Use the `compose.remember()` function to create state variables. When a state variable's value is updated using its `:set()` method, it automatically triggers a UI recomposition (redraw) of only the parts of the UI that depend on that specific state. States can be tagged and persisted across computer reboots.
*   **Component-based:** Build your UI from a set of built-in components like `Column`, `Row`, `Text`, `Button`, and `ProgressBar`. Components are reusable and can be nested to create complex layouts.
*   **Modifiers:** Chainable objects (`compose.Modifier`) used to apply styling and behavior to components. This includes attributes like background colors, padding, text scaling, borders, and layout behaviors such as `fillMaxWidth()` and `fillMaxHeight()`.
*   **Event Handling:** Simple `onClick` handlers for interactive components, allowing for user interaction.

## Core Concepts

### Components

Components are the basic building blocks of your UI. They are hierarchical, meaning they can contain other components as children, forming a UI tree. Each component has properties (`props`) that define its appearance and behavior. They implement a `draw()` method responsible for rendering themselves and their children onto a ComputerCraft monitor.

```lua
-- A Column with a Text and a Row of Buttons
compose.Column({
  compose.Text({text = "Hello, World!"}),
  compose.Row({
    compose.Button({text = "A"}),
    compose.Button({text = "B"})
  })
})
```

### State

State is data that can change over time. When state changes, the part of the UI that uses it is automatically updated. You create state with `compose.remember(initialValue, tag?, persist?)`:

```lua
-- Create a state variable for a counter
local counter = compose.remember(0, "myCounter", true) -- "myCounter" is a tag for persistence

-- Later, in a Button's onClick handler:
counter:set(counter:get() + 1)
```
The `tag` parameter is optional but recommended for persistent states, allowing the state to be saved and reloaded across reboots. The `persist` parameter (boolean) determines if the state should be saved.

### Modifiers

Modifiers are used to customize the appearance and behavior of components. They are chained together to apply multiple properties.

```lua
-- Example of a Text component with a background and padding
compose.Text({
  text = "Styled Text",
  modifier = compose.Modifier:new()
    :background(colors.blue)
    :padding(1, 2) -- 1 char padding left/right, 2 chars top/bottom
    :fillMaxWidth()
})
```

### Application Lifecycle (`compose.src.core.App`)

The `App` class manages the entire application lifecycle, from initialization to destruction. It runs a main event loop, handling `monitor_touch` events (for clicks) and scheduling UI re-compositions when state changes. It tracks various lifecycle states (Initialized, Created, Started, Resumed, Paused, Stopped, Destroyed).

### Layout System (`compose.src.model/Arrangement.lua`, `HorizontalAlignment.lua`, `VerticalAlignment.lua`)

`Column` and `Row` components are used for arranging children vertically and horizontally, respectively. They support various `Arrangement` options to distribute space among children and `HorizontalAlignment`/`VerticalAlignment` to control the alignment of children within their parent.

## Getting Started

1.  **Installation:** Place the `compose` directory into your computer's root directory in the Minecraft world. If using the `cc-manager` project, the `install.lua` script will handle this for you.
2.  **Create your UI file:** Create a new file (e.g., `my_app.lua`).
3.  **Write the code:**

    ```lua
    -- my_app.lua

    -- Load the compose library
    local compose = require("compose.src.compose")

    -- Find the main monitor to draw on
    local monitor = peripheral.find("monitor") or error("No monitor found", 0)

    -- Define the UI in a composable function
    local function App()
      -- Create a state variable for a counter
      local counter = compose.remember(0)

      return compose.Column({
        compose.Text({text = "Counter: " .. counter:get()}),
        compose.Button({
          text = "Increment",
          onClick = function()
            counter:set(counter:get() + 1)
          end
        })
      })
    end

    -- Render the application on the monitor
    compose.render(App, monitor)
    ```

4.  **Run it:** Save the file and run `my_app.lua` in the computer's terminal.

## Available Components

*   `compose.Column(props, children)`: Arranges its children vertically.
    *   `props.verticalArrangement`: (Optional) How children are spaced vertically (e.g., `compose.Arrangement.SpaceEvenly`, `compose.Arrangement.SpaceBetween`, `compose.Arrangement.SpaceAround`, `compose.Arrangement.SpacedBy`).
    *   `props.horizontalAlignment`: (Optional) How children are aligned horizontally within the column (e.g., `compose.HorizontalAlignment.Start`, `compose.HorizontalAlignment.Center`, `compose.HorizontalAlignment.End`).
    *   `props.spacing`: (Optional, for `SpacedBy`) Number of characters between children.
*   `compose.Row(props, children)`: Arranges its children horizontally.
    *   `props.horizontalArrangement`: (Optional) How children are spaced horizontally (e.g., `compose.Arrangement.SpaceEvenly`, `compose.Arrangement.SpaceBetween`, `compose.Arrangement.SpaceAround`, `compose.Arrangement.SpacedBy`).
    *   `props.verticalAlignment`: (Optional) How children are aligned vertically within the row (e.g., `compose.VerticalAlignment.Top`, `compose.VerticalAlignment.Center`, `compose.VerticalAlignment.Bottom`).
    *   `props.spacing`: (Optional, for `SpacedBy`) Number of characters between children.
*   `compose.Text(props)`: Displays a line of text.
    *   `props.text`: The string to display.
    *   `props.textColor`: (Optional) Color of the text.
    *   `props.textScale`: (Optional) Scale factor for the text (e.g., 2 for double size).
*   `compose.Button(props)`: A clickable button with text.
    *   `props.text`: The text to display on the button.
    *   `props.onClick`: A function to call when the button is clicked.
    *   `props.textColor`: (Optional) Color of the button text.
    *   `props.backgroundColor`: (Optional) Background color of the button.
*   `compose.ProgressBar(props)`: Displays a simple animated progress indicator with text.
    *   `props.text`: The text to display below the animation.

## API Reference

### `compose.render(rootComposable, monitor)`

Renders the `rootComposable` function onto the specified `monitor` peripheral and starts the main event loop. This function is blocking and will run until `compose.exit()` is called or the computer is turned off.

### `compose.remember(initialValue, tag?, persist?)`

Creates and remembers a state variable.
*   `initialValue`: The initial value of the state.
*   `tag`: (Optional) A unique string identifier for the state. Required if `persist` is true.
*   `persist`: (Optional) A boolean indicating whether the state should be saved to disk (`states.dat`) and reloaded on startup. Defaults to `false`.

Returns a state object with the following methods:
*   `:get(transformFn?)`: Retrieves the current value of the state. An optional `transformFn` can be provided to derive a new value from the state.
*   `:set(newValue)`: Sets a new value for the state. If the new value is different from the current one, it triggers a UI re-composition.

### `compose.exit()`

Stops the currently running Compose application, clears the monitor, and terminates the application's main loop.

### `compose.Modifier:new()`

Creates a new Modifier instance. Modifiers are typically chained together.

**Modifier Methods:**

*   `:background(color)`: Sets the background color of the component.
*   `:padding(left, top?, right?, bottom?)`: Sets the padding around the component. Can be called with 1 (all sides), 2 (horizontal, vertical), or 4 arguments (left, top, right, bottom).
*   `:textScale(scale)`: Sets the scale factor for text within the component.
*   `:border(width, color)`: Adds a border around the component with the specified `width` and `color`.
*   `:fillMaxWidth()`: Makes the component expand to fill the maximum available width provided by its parent.
*   `:fillMaxHeight()`: Makes the component expand to fill the maximum available height provided by its parent.
*   `:fillMaxSize()`: A convenience method that calls both `:fillMaxWidth()` and `:fillMaxHeight()`.
*   `:clickable(onClick)`: Makes the component clickable. The `onClick` function will be executed when the component is touched.

## Example (`examples/hello.lua`)

The `examples/hello.lua` file demonstrates a simple counter application with buttons, text displays, and various layout arrangements using `Column` and `Row` with different modifiers and alignments. It showcases how `compose.remember` is used to manage state and how `compose.exit()` can terminate the application.

```lua
-- examples/hello.lua content (as provided in previous context)
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