port module GraphqlSubscription exposing (cmdAndSub)

import Graphql.Document
import Graphql.Operation
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Json.Decode


cmdAndSub :
    SelectionSet decodesTo Graphql.Operation.RootSubscription
    -> (Result Json.Decode.Error decodesTo -> msg)
    -> { cmd : Cmd msg, sub : Sub msg }
cmdAndSub =
    registerSubscriptionHelper startSubscription subscriptionPayloadReceived


registerSubscriptionHelper :
    (String -> Cmd msg)
    -> ((Json.Decode.Value -> msg) -> Sub msg)
    -> SelectionSet decodesTo Graphql.Operation.RootSubscription
    -> (Result Json.Decode.Error decodesTo -> msg)
    -> { cmd : Cmd msg, sub : Sub msg }
registerSubscriptionHelper startSubscriptionPort subscriptionPayloadPort subscription gotSubscriptionPayloadMsg =
    { cmd = subscription |> Graphql.Document.serializeSubscription |> startSubscriptionPort
    , sub =
        subscriptionPayloadPort
            (\payload ->
                payload
                    |> Json.Decode.decodeValue (Graphql.Document.decoder subscription)
                    |> gotSubscriptionPayloadMsg
            )
    }


port startSubscription : String -> Cmd msg


port subscriptionPayloadReceived : (Json.Decode.Value -> msg) -> Sub msg
