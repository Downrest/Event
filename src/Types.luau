local Types = {}

export type DefaultSignature = () -> ()

type function PushFrontSignature(append: type, signature: type): type
    if signature.tag ~= "function" then
        signature = types.newfunction()
    end

    local typeParameters = signature:parameters()

    if typeParameters.head then
        for headIndex = #typeParameters.head, 1, -1 do
            local headType = typeParameters.head[headIndex]
            typeParameters.head[headIndex + 1] = headType
        end
        typeParameters.head[1] = append
    else
        typeParameters.head = {append}
    end

    return types.newfunction(typeParameters)
end

--[[
    RELIABLE REMOTE EVENTS
]]

export type ReliableClientFire<
    clientToServerSignature = DefaultSignature,
    serverToClientSignature = DefaultSignature
> = {
    FireServer: PushFrontSignature<
        any,
        clientToServerSignature
    >;
}
export type ReliableClientListener<
    clientToServerSignature = DefaultSignature,
    serverToClientSignature = DefaultSignature
> = {
    Connect: (
        self: ReliableClientListener<clientToServerSignature, serverToClientSignature>, 
        callback: serverToClientSignature
    ) -> RBXScriptConnection;
    ConnectParallel: (
        self: ReliableClientListener<clientToServerSignature, serverToClientSignature>, 
        callback: serverToClientSignature
    ) -> RBXScriptConnection;
    Once: (
        self: ReliableClientListener<clientToServerSignature, serverToClientSignature>, 
        callback: serverToClientSignature
    ) -> RBXScriptConnection;
}
export type ReliableServerFire<
    clientToServerSignature = DefaultSignature,
    serverToClientSignature = DefaultSignature
> = {
    FireClient: PushFrontSignature<
        any, 
        PushFrontSignature<Player, serverToClientSignature>
    >;
    FireAllClients: PushFrontSignature<
        any, 
        serverToClientSignature
    >;
}
export type ReliableServerListener<
    clientToServerSignature = DefaultSignature,
    serverToClientSignature = DefaultSignature
> = {
    Connect: (
        self: ReliableServerListener<clientToServerSignature, serverToClientSignature>, 
        callback: PushFrontSignature<Player, clientToServerSignature>
    ) -> RBXScriptConnection;
    ConnectParallel: (
        self: ReliableServerListener<clientToServerSignature, serverToClientSignature>, 
        callback: PushFrontSignature<Player, clientToServerSignature>
    ) -> RBXScriptConnection;
    Once: (
        self: ReliableServerListener<clientToServerSignature, serverToClientSignature>, 
        callback: PushFrontSignature<Player, clientToServerSignature>
    ) -> RBXScriptConnection;
}

export type ReliableEvent<
    clientToServerSignature = DefaultSignature,
    serverToClientSignature = DefaultSignature
> = {
    client: 
        ReliableClientFire<clientToServerSignature, serverToClientSignature>
        & {
            OnClientEvent: ReliableClientListener<clientToServerSignature, serverToClientSignature>;
        }
    ;
    server: 
        ReliableServerFire<clientToServerSignature, serverToClientSignature>
        & {
            OnServerEvent: ReliableServerListener<clientToServerSignature, serverToClientSignature>;
        }
    ;
}
export type PrivateReliableEvent = {
    _remoteEvent: RemoteEvent
}

export type ClientToServerReliable<signature = DefaultSignature> = ReliableEvent<signature, any>
export type ServerToClientReliable<signature = DefaultSignature> = ReliableEvent<any, signature>

return Types
