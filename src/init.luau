local RunService = game:GetService("RunService")

local Types = require(script.Types)

local Event = {}

export type ReliableEvent<
    clientToServerSignature = Types.DefaultSignature,
    serverToClientSignature = Types.DefaultSignature
> = Types.ReliableEvent<clientToServerSignature, serverToClientSignature>
export type ClientToServerReliable<signature = Types.DefaultSignature> = Types.ClientToServerReliable<signature>
export type ServerToClientReliable<signature = Types.DefaultSignature> = Types.ServerToClientReliable<signature>

local function assertClient()
    assert(RunService:IsClient(), "Attempted to run client-only function!")
end

local function assertServer()
    assert(RunService:IsServer(), "Attempted to run server-only function!")
end

function Event.newReliable<
    clientToServerSignature,
    serverToClientSignature
>(): ReliableEvent<clientToServerSignature, serverToClientSignature>
    local self = {
        client = {
            OnClientEvent = {};
        };
        server = {
            OnServerEvent = {};
        };
    }:: ReliableEvent<clientToServerSignature, serverToClientSignature> & Types.PrivateReliableEvent

    -- upvalue
    local remoteEvent = Instance.new("RemoteEvent")

    -- client
    do
        function self.client.FireServer(self: Types.ReliableClientFire, ...)
            assertClient()

            remoteEvent:FireServer(...)
        end

        function self.client.OnClientEvent.Connect(self: Types.ReliableClientListener, callback)
            assertClient()

            return remoteEvent.OnClientEvent:Connect(callback)
        end
        function self.client.OnClientEvent.ConnectParallel(self: Types.ReliableClientListener, callback)
            assertClient()

            return remoteEvent.OnClientEvent:ConnectParallel(callback)
        end
        function self.client.OnClientEvent.Once(self: Types.ReliableClientListener, callback)
            assertClient()

            return remoteEvent.OnClientEvent:Once(callback)
        end
    end

    -- server
    do
        function self.server.FireClient(self: Types.ReliableServerFire, player: Player, ...)
            assertServer()

            remoteEvent:FireClient(player, ...)
        end
        function self.server.FireAllClients(self: Types.ReliableServerListener, ...)
            assertServer()

            remoteEvent:FireAllClients(...)
        end

        function self.server.OnServerEvent.Connect(self: ReliableEvent & Types.PrivateReliableEvent, callback)
            assertServer()
            
            return remoteEvent.OnClientEvent:Connect(callback)
        end
        function self.server.OnServerEvent.ConnectParallel(self: ReliableEvent & Types.PrivateReliableEvent, callback)
            assertServer()
            
            return remoteEvent.OnClientEvent:ConnectParallel(callback)
        end
        function self.server.OnServerEvent.Once(self: ReliableEvent & Types.PrivateReliableEvent, callback)
            assertServer()
            
            return remoteEvent.OnClientEvent:Once(callback)
        end
    end

    return self
end

return Event
