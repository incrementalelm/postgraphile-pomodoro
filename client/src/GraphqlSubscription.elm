port module GraphqlSubscription exposing (SubscriptionError, cmdAndSub)

import Graphql.Document
import Graphql.Http
import Graphql.Http.GraphqlError as GraphqlError
import Graphql.Operation
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Json.Decode
import Json.Encode


cmdAndSub :
    SelectionSet decodesTo Graphql.Operation.RootSubscription
    -> (Result (SubscriptionError decodesTo) decodesTo -> msg)
    -> { cmd : Cmd msg, sub : Sub msg }
cmdAndSub =
    registerSubscriptionHelper elmToJs jsToElm


registerSubscriptionHelper :
    (Json.Encode.Value -> Cmd msg)
    -> ((Json.Decode.Value -> msg) -> Sub msg)
    -> SelectionSet decodesTo Graphql.Operation.RootSubscription
    -> (Result (SubscriptionError decodesTo) decodesTo -> msg)
    -> { cmd : Cmd msg, sub : Sub msg }
registerSubscriptionHelper elmToJsPort subscriptionPayloadPort subscriptionQuery gotSubscriptionPayloadMsg =
    { cmd =
        subscriptionQuery
            |> startSubscriptionMsg
            |> elmToJsPort
    , sub =
        subscriptionPayloadPort
            (\payload ->
                payload
                    |> payloadToResponse subscriptionQuery
                    |> gotSubscriptionPayloadMsg
            )
    }


startSubscriptionMsg :
    SelectionSet decodesTo Graphql.Operation.RootSubscription
    -> Json.Encode.Value
startSubscriptionMsg subscriptionQuery =
    Json.Encode.object
        [ ( "event", Json.Encode.string "startSubscription" )
        , ( "subscriptionQuery"
          , subscriptionQuery
                |> Graphql.Document.serializeSubscription
                |> Json.Encode.string
          )
        ]


payloadToResponse :
    SelectionSet decodesTo Graphql.Operation.RootSubscription
    -> Json.Decode.Value
    -> Result (SubscriptionError decodesTo) decodesTo
payloadToResponse subscriptionQuery subscriptionPayload =
    case
        Json.Decode.decodeValue (decoderOrError (subscriptionQuery |> Graphql.Document.decoder))
            subscriptionPayload
    of
        Ok dataResult ->
            case dataResult of
                Ok decodedPayload ->
                    Ok decodedPayload

                Err graphqlError ->
                    GraphqlError graphqlError |> Err

        Err jsonDecodeError ->
            Err <| CouldNotDecode jsonDecodeError


type SubscriptionError decodesTo
    = GraphqlError ( GraphqlError.PossiblyParsedData decodesTo, List GraphqlError.GraphqlError )
    | CouldNotDecode Json.Decode.Error


decoderOrError : Json.Decode.Decoder a -> Json.Decode.Decoder (DataResult a)
decoderOrError decoder =
    Json.Decode.oneOf
        [ errorDecoder decoder
        , decoder |> Json.Decode.map Ok
        ]


type alias DataResult parsedData =
    Result ( GraphqlError.PossiblyParsedData parsedData, List GraphqlError.GraphqlError ) parsedData


errorDecoder : Json.Decode.Decoder a -> Json.Decode.Decoder (DataResult a)
errorDecoder decoder =
    Json.Decode.oneOf
        [ decoder |> Json.Decode.map GraphqlError.ParsedData |> Json.Decode.andThen decodeErrorWithData
        , Json.Decode.field "data" Json.Decode.value |> Json.Decode.map GraphqlError.UnparsedData |> Json.Decode.andThen decodeErrorWithData
        ]


decodeErrorWithData : GraphqlError.PossiblyParsedData a -> Json.Decode.Decoder (DataResult a)
decodeErrorWithData data =
    GraphqlError.decoder |> Json.Decode.map (Tuple.pair data) |> Json.Decode.map Err


port elmToJs : Json.Encode.Value -> Cmd msg


port jsToElm : (Json.Decode.Value -> msg) -> Sub msg
