--- @enum LifecycleState
--- Represents the lifecycle state of a Compose application.
local LifecycleState = {
  Initialized = "Initialized",
  Created = "Created",
  Started = "Started",
  Resumed = "Resumed",
  Paused = "Paused",
  Stopped = "Stopped",
  Destroyed = "Destroyed",
}

return LifecycleState
