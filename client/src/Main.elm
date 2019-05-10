module Main exposing (main)

import Api.Object.Timer
import Api.Query as Query
import Api.ScalarCodecs
import Browser
import Browser.Navigation
import Element exposing (Element)
import Element.Border
import Element.Events
import Element.Input
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)
import Request exposing (Response)
import Url exposing (Url)


selection : SelectionSet (Maybe Api.ScalarCodecs.Datetime) RootQuery
selection =
    Query.activeTimer Api.Object.Timer.createdAt


type Msg
    = NoOp


type alias Model =
    Int


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( 0, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Postgraphile Pomodoro"
    , body =
        Element.none
            |> Element.layout []
            |> List.singleton
    }
