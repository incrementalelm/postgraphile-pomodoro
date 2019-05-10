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
import Element.Keyed
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)
import Request exposing (Response)
import Time
import Timer exposing (Timer)
import Url exposing (Url)


selection : SelectionSet (Maybe Timer) RootQuery
selection =
    Query.activeTimer
        Timer.selection


makeRequest : Cmd Msg
makeRequest =
    Request.query GotTimerResponse selection


type Msg
    = GotTimerResponse (Response (Maybe Timer))
    | GotCurrentTime Time.Posix


type alias Model =
    { activeTimerResponse : Response (Maybe Timer)
    , now : Time.Posix
    }


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { activeTimerResponse = RemoteData.Loading
      , now = Time.millisToPosix 0
      }
    , makeRequest
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTimerResponse timerResponse ->
            ( { model | activeTimerResponse = timerResponse }, Cmd.none )

        GotCurrentTime now ->
            ( { model | now = now }, Cmd.none )


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \model -> Time.every 10 GotCurrentTime
        }


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Postgraphile Pomodoro"
    , body =
        (case model.activeTimerResponse of
            RemoteData.Loading ->
                Element.text "Loading..."

            RemoteData.Success response ->
                Timer.view model.now response

            RemoteData.NotAsked ->
                Element.text "..."

            RemoteData.Failure error ->
                Element.paragraph [] [ Element.text (Debug.toString error) ]
        )
            |> Element.layout []
            |> List.singleton
    }
