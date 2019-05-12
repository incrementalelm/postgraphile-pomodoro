port module GraphqlSubscription exposing (register)

import Graphql.Document
import Graphql.Operation
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Json.Decode


register :
    SelectionSet decodesTo Graphql.Operation.RootSubscription
    -> (Result Json.Decode.Error decodesTo -> msg)
    -> ( Cmd msg, Sub msg )
register =
    registerSubscriptionHelper startSubscription subscriptionPayloadReceived


registerSubscriptionHelper :
    (String -> Cmd msg)
    -> ((Json.Decode.Value -> msg) -> Sub msg)
    -> SelectionSet decodesTo Graphql.Operation.RootSubscription
    -> (Result Json.Decode.Error decodesTo -> msg)
    -> ( Cmd msg, Sub msg )
registerSubscriptionHelper startSubscriptionPort subscriptionPayloadPort subscription gotSubscriptionPayloadMsg =
    ( subscription |> Graphql.Document.serializeSubscription |> startSubscriptionPort
    , subscriptionPayloadPort
        (\payload ->
            payload
                |> Json.Decode.decodeValue (Graphql.Document.decoder subscription)
                |> gotSubscriptionPayloadMsg
        )
    )


port startSubscription : String -> Cmd msg


port subscriptionPayloadReceived : (Json.Decode.Value -> msg) -> Sub msg
