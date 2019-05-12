port module RegisterGraphqlSubscription exposing (startSubscription, subscriptionPayloadReceived)

import Json.Decode


port startSubscription : String -> Cmd msg


port subscriptionPayloadReceived : (Json.Decode.Value -> msg) -> Sub msg
