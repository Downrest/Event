# Event
A typed remote event wrapper, taking advantage of function types (...) -> () for typechecking parameters on both firing and listening.

By default, Event creates the remote instances behind the scenes, ensuring both the server and client access the same event instances.
* `newReliable(remoteName: string)`
* `newUnreliable(unreliableRemoteName: string)`

Alternatively, you can also reference existing remote instances.
* `wrapReliable(remoteEvent: RemoteEvent)`
* `wrapUnreliable(unreliableRemoteEvent: UnreliableRemoteEvent)`

Event's API is *almost* 1:1 with Roblox remote instances' API, with the exception having methods split into `client` and `server`:
```lua
local event = Event.newReliable():: Event.ServerToClient<(foo: boolean, fee: string) -> ()>

-- will automatically define the parameters `foo` and `fee` with the defined types
event.client.OnClientEvent:Connect(function(foo: boolean, fee: string) 
    ...
end)

event.server:FireAllClients(true, false) -- TypeError: Expected this to be `string`, but got `boolean`
```

The usage of type functions is heavily inspired from how [NamedSignal](https://github.com/averlyst/NamedSignal) handles its signal signatures, allowing anonymous autofills to include the parameter names + further verbosity when casting types.
