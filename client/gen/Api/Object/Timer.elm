-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.Timer exposing (createdAt, id, kind, userId)

import Api.Enum.TimerKind
import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.ScalarCodecs
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


id : SelectionSet Int Api.Object.Timer
id =
    Object.selectionForField "Int" "id" [] Decode.int


createdAt : SelectionSet Api.ScalarCodecs.Datetime Api.Object.Timer
createdAt =
    Object.selectionForField "ScalarCodecs.Datetime" "createdAt" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecDatetime |> .decoder)


userId : SelectionSet Int Api.Object.Timer
userId =
    Object.selectionForField "Int" "userId" [] Decode.int


kind : SelectionSet Api.Enum.TimerKind.TimerKind Api.Object.Timer
kind =
    Object.selectionForField "Enum.TimerKind.TimerKind" "kind" [] Api.Enum.TimerKind.decoder
