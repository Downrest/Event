# Event
A typed remote event wrapper, taking advantage of function types (...) -> () for defined parameters on both the firing and listening aspects of the API. Supports both reliable and unreliable remote events.

Holds the same API as remote events, with the only exception being its distinction between `client` and `server` methods. Usage is as seen below:
```lua
local event = Event.newReliable():: Event.ServerToClient<(foo: boolean, fee: string) -> ()>

-- will automatically define the parameters `foo` and `fee` with the defined types
event.client.OnClientEvent:Connect(function(foo: boolean, fee: string) 
    ...
end)

event.server:FireAllClients(true, false) -- TypeError: Expected this to be `string`, but got `boolean`
```

The usage of type functions is heavily inspired from how [NamedSignal](https://github.com/averlyst/NamedSignal) handles its signal signatures, go check it out!
