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

local function newEvent<
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
            
            return remoteEvent.OnClientEvent:Connect(callback)
        end
        function self.server.OnServerEvent.ConnectParallel(self: Event & Types.PrivateEvent, callback)
            assertServer()
            
            return remoteEvent.OnClientEvent:ConnectParallel(callback)
        end
        function self.server.OnServerEvent.Once(self: Event & Types.PrivateEvent, callback)
            assertServer()
            
            return remoteEvent.OnClientEvent:Once(callback)
        end
    end

    return self
end

function Event.newReliable<
    clientToServerSignature,
    serverToClientSignature
>(): Event<clientToServerSignature, serverToClientSignature>
    return newEvent<<clientToServerSignature, serverToClientSignature>>(
        Instance.new("RemoteEvent")
    )
end

function Event.newUnreliable<
    clientToServerSignature,
    serverToClientSignature
>(): Event<clientToServerSignature, serverToClientSignature>
    return newEvent<<clientToServerSignature, serverToClientSignature>>(
        Instance.new("UnreliableRemoteEvent")
    )
end

return Event
