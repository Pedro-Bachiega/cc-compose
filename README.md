# Compose for CC: Tweaked

A declarative UI framework for the Minecraft mod [CC: Tweaked](https://tweaked.cc/), heavily inspired by modern UI toolkits like Jetpack Compose and SwiftUI.

This framework allows you to build complex, stateful User Interfaces for in-game computers by writing simple, declarative Lua code.

## Features

*   **Declarative:** Describe your UI with a nested structure of components. The framework handles the rendering and updates.
*   **Stateful:** Use the `compose.remember()` function to create state variables. The UI automatically re-renders when the state changes.
*   **Component-based:** Build your UI from a set of built-in components like `Column`, `Row`, `Text`, and `Button`.
*   **Modifiers:** Customize components with modifiers for things like background colors.
*   **Event Handling:** Simple `onClick` handlers for interactive components.

## Core Concepts

### Components

Components are the basic building blocks of your UI. You can nest them to create complex layouts.

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

State is data that can change over time. When state changes, the part of the UI that uses it is automatically updated. You create state with `compose.remember()`:

```lua
-- Create a state variable for a counter
local counter = compose.remember(0)

-- Later, in a Button's onClick handler:
counter:set(counter:get() + 1)
```

## Getting Started

1.  **Installation:** Place the `compose` directory into your computer's root directory in the Minecraft world.
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

*   `compose.Column`: Arranges its children vertically.
*   `compose.Row`: Arranges its children horizontally.
*   `compose.Text`: Displays a line of text.
*   `compose.Button`: A clickable button with text.

## API Reference

### `compose.render(rootComposable, monitor)`

Renders the root composable function onto the specified monitor and starts the event loop.

### `compose.remember(initialValue)`

Creates and remembers a state variable. Returns a state object with `:get()` and `:set()` methods.

### `compose.exit()`

Stops the application and clears the monitor.
