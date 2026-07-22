# Event
A typed remote event wrapper, taking advantage of function types (...) -> () for typechecking parameters on both the firing and listening aspects of the API. 

By default, Event handles the creation of the remote instances behind the scenes, ensuring both the server and client can access the same event instances.
* newReliable(remoteName: string)
* newUnreliable(unreliableRemoteName: string)

Alternatively, you can also reference static remote instances.
* wrapReliable(remoteEvent: RemoteEvent)
* wrapUnreliable(unreliableRemoteEvent: UnreliableRemoteEvent)

Holds the same API as remote events, with the only exception being its distinction between `client` and `server` methods:
```lua
local event = Event.newReliable():: Event.ServerToClient<(foo: boolean, fee: string) -> ()>

-- will automatically define the parameters `foo` and `fee` with the defined types
event.client.OnClientEvent:Connect(function(foo: boolean, fee: string) 
    ...
end)

event.server:FireAllClients(true, false) -- TypeError: Expected this to be `string`, but got `boolean`
```

The usage of type functions is heavily inspired from how [NamedSignal](https://github.com/averlyst/NamedSignal) handles its signal signatures, allowing anonymous autofills to include the parameter names + further verbosity when casting types.
