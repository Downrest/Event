local RunService = game:GetService("RunService")

local Types = require(script.Types)

local Event = {}

export type Event<
    clientToServerSignature = Types.DefaultSignature,
    serverToClientSignature = Types.DefaultSignature
> = Types.Event<clientToServerSignature, serverToClientSignature>
export type ClientToServer<signature = Types.DefaultSignature> = Types.ClientToServer<signature>
export type ServerToClient<signature = Types.DefaultSignature> = Types.ServerToClient<signature>

local function assertClient()
    assert(RunService:IsClient(), "Attempted to run client-only function!")
end

local function assertServer()
    assert(RunService:IsServer(), "Attempted to run server-only function!")
end

local function getReliableEvent(name: string): RemoteEvent
    local event = script:FindFirstChild(name)
    if not event then -- allowing client/server boundary to access the same instance
        event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = script
    end

    return (event:: RemoteEvent)
end

local function getUnreliableEvent(name: string): UnreliableRemoteEvent
    local event = script:FindFirstChild(name)
    if not event then -- allowing client/server boundary to access the same instance
        event = Instance.new("UnreliableRemoteEvent")
        event.Name = name
        event.Parent = script
    end

    return (event:: UnreliableRemoteEvent)
end

local function wrapEvent<
    clientToServerSignature,
    serverToClientSignature
>(remoteEvent: any): Event<clientToServerSignature, serverToClientSignature>
    local self = {
        client = {
            OnClientEvent = {};
        };
        server = {
            OnServerEvent = {};
        };
    }:: Event<clientToServerSignature, serverToClientSignature> & Types.PrivateEvent

    -- client
    do
        function self.client.FireServer(self: Types.ClientFire, ...)
            assertClient()

            remoteEvent:FireServer(...)
        end

        function self.client.OnClientEvent.Connect(self: Types.ClientListener, callback)
            assertClient()

            return remoteEvent.OnClientEvent:Connect(callback)
        end
        function self.client.OnClientEvent.ConnectParallel(self: Types.ClientListener, callback)
            assertClient()

            return remoteEvent.OnClientEvent:ConnectParallel(callback)
        end
        function self.client.OnClientEvent.Once(self: Types.ClientListener, callback)
            assertClient()

            return remoteEvent.OnClientEvent:Once(callback)
        end
    end

    -- server
    do
        function self.server.FireClient(self: Types.ServerFire, player: Player, ...)
            assertServer()

            remoteEvent:FireClient(player, ...)
        end
        function self.server.FireAllClients(self: Types.ServerListener, ...)
            assertServer()

            remoteEvent:FireAllClients(...)
        end

        function self.server.OnServerEvent.Connect(self: Event & Types.PrivateEvent, callback)
            assertServer()
            
            return remoteEvent.OnServerEvent:Connect(callback)
        end
        function self.server.OnServerEvent.ConnectParallel(self: Event & Types.PrivateEvent, callback)
            assertServer()
            
            return remoteEvent.OnServerEvent:ConnectParallel(callback)
        end
        function self.server.OnServerEvent.Once(self: Event & Types.PrivateEvent, callback)
            assertServer()
            
            return remoteEvent.OnServerEvent:Once(callback)
        end
    end

    return self
end

--[[
    RELIABLE REMOTE EVENTS
]]

function Event.newReliable<
    clientToServerSignature,
    serverToClientSignature
>(
    name: string
): Event<clientToServerSignature, serverToClientSignature>

    return wrapEvent<<clientToServerSignature, serverToClientSignature>>(
        getReliableEvent(name)
    )
end

function Event.wrapReliable<
    clientToServerSignature,
    serverToClientSignature
>(
    remoteEvent: RemoteEvent
): Event<clientToServerSignature, serverToClientSignature>

    return wrapEvent<<clientToServerSignature, serverToClientSignature>>(
        remoteEvent
    )
end

--[[
    UNRELIABLE REMOTE EVENTS
]]

function Event.newUnreliable<
    clientToServerSignature,
    serverToClientSignature
>(
    name: string
): Event<clientToServerSignature, serverToClientSignature>

    return wrapEvent<<clientToServerSignature, serverToClientSignature>>(
        getUnreliableEvent(name)
    )
end

function Event.wrapUnreliable<
    clientToServerSignature,
    serverToClientSignature
>(
    unreliableRemoteEvent: UnreliableRemoteEvent
): Event<clientToServerSignature, serverToClientSignature>

    return wrapEvent<<clientToServerSignature, serverToClientSignature>>(
        unreliableRemoteEvent
    )
end

return Event
