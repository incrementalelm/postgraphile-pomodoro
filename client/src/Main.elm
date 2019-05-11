module Main exposing (main)

import Api.Enum.TimerKind
import Api.Mutation
import Api.Object
import Api.Object.StartTimerPayload
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
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
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


startTimerSelection : SelectionSet (Maybe Timer) RootMutation
startTimerSelection =
    Api.Mutation.startTimer
        { input = { kind = Api.Enum.TimerKind.Work, clientMutationId = Absent }
        }
        (Api.Object.StartTimerPayload.timer Timer.selection)
        |> SelectionSet.map (Maybe.withDefault Nothing)


startTimer : Cmd Msg
startTimer =
    Request.mutation GotTimerResponse startTimerSelection


makeRequest : Cmd Msg
makeRequest =
    Request.query GotTimerResponse selection


type Msg
    = GotTimerResponse (Response (Maybe Timer))
    | GotCurrentTime Time.Posix
    | ClickedStartTimer


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

        ClickedStartTimer ->
            ( model, startTimer )


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
                Element.column
                    [ Element.centerX
                    ]
                    [ Timer.view model.now response
                    , startTimerButton (response |> Maybe.map .kind)
                    ]

            RemoteData.NotAsked ->
                Element.text "..."

            RemoteData.Failure error ->
                Element.paragraph [] [ Element.text (Debug.toString error) ]
        )
            |> Element.layout
                [ Element.padding 20
                , Element.width Element.fill
                ]
            |> List.singleton
    }


startTimerButton : Maybe Api.Enum.TimerKind.TimerKind -> Element Msg
startTimerButton maybeKind =
    Element.el
        [ Element.Events.onClick ClickedStartTimer
        , Element.pointer
        , Element.Border.width 2
        , Element.padding 8
        ]
        ((case maybeKind of
            Just kind ->
                case kind of
                    Api.Enum.TimerKind.Work ->
                        "Start New Timer"

                    Api.Enum.TimerKind.ShortBreak ->
                        "Start Timer"

                    Api.Enum.TimerKind.LongBreak ->
                        "Start Timer"

            Nothing ->
                "Start Timer"
         )
            |> Element.text
        )
