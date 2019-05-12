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
    registerSubscriptionHelper initializeSubscription subscriptionPayloadReceived


registerSubscriptionHelper :
    (String -> Cmd msg)
    -> ((Json.Decode.Value -> msg) -> Sub msg)
    -> SelectionSet decodesTo Graphql.Operation.RootSubscription
    -> (Result Json.Decode.Error decodesTo -> msg)
    -> { cmd : Cmd msg, sub : Sub msg }
registerSubscriptionHelper initializeSubscriptionPort subscriptionPayloadPort subscription gotSubscriptionPayloadMsg =
    { cmd = subscription |> Graphql.Document.serializeSubscription |> initializeSubscriptionPort
    , sub =
        subscriptionPayloadPort
            (\payload ->
                payload
                    |> Json.Decode.decodeValue (Graphql.Document.decoder subscription)
                    |> gotSubscriptionPayloadMsg
            )
    }


port initializeSubscription : String -> Cmd msg


port subscriptionPayloadReceived : (Json.Decode.Value -> msg) -> Sub msg
