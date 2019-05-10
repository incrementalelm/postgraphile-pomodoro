module Main exposing (main)

import Api.Enum.TimerKind
import Api.Object
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
import Time
import Url exposing (Url)


type alias Timer =
    { createdAt : Time.Posix
    , kind : Api.Enum.TimerKind.TimerKind
    }


selection : SelectionSet (Maybe Timer) RootQuery
selection =
    Query.activeTimer
        timerSelection


timerSelection : SelectionSet Timer Api.Object.Timer
timerSelection =
    SelectionSet.map2 Timer
        Api.Object.Timer.createdAt
        Api.Object.Timer.kind


makeRequest : Cmd Msg
makeRequest =
    Request.query GotTimerResponse selection


type Msg
    = GotTimerResponse (Response (Maybe Timer))


type alias Model =
    Response (Maybe Timer)


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( RemoteData.Loading, makeRequest )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTimerResponse timerResponse ->
            ( timerResponse, Cmd.none )


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }


timerView : Maybe Timer -> Element msg
timerView maybeTimer =
    case maybeTimer of
        Just timer ->
            Element.column []
                [ Element.text (Api.Enum.TimerKind.toString timer.kind)
                , Element.text "Timer is running"
                ]

        Nothing ->
            Element.text "No active timer"


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Postgraphile Pomodoro"
    , body =
        (case model of
            RemoteData.Loading ->
                Element.text "Loading..."

            RemoteData.Success response ->
                timerView response

            RemoteData.NotAsked ->
                Element.text "..."

            RemoteData.Failure error ->
                Element.paragraph [] [ Element.text (Debug.toString error) ]
        )
            |> Element.layout []
            |> List.singleton
    }
