module Timer exposing (Timer, selection, view)

import Api.Enum.TimerKind
import Api.Object
import Api.Object.Timer
import Api.Query as Query
import Element exposing (Element)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemainingSeconds
import Time


type alias Timer =
    { createdAt : Time.Posix
    , kind : Api.Enum.TimerKind.TimerKind
    }


selection : SelectionSet Timer Api.Object.Timer
selection =
    SelectionSet.map2 Timer
        Api.Object.Timer.createdAt
        Api.Object.Timer.kind


view : Time.Posix -> Maybe Timer -> Element msg
view now maybeTimer =
    case maybeTimer of
        Just timer ->
            case
                RemainingSeconds.between
                    { now = now
                    , timerCreated = timer.createdAt
                    , timerDurationMinutes = 25
                    }
            of
                Just remaining ->
                    Element.column []
                        [ Element.text (Api.Enum.TimerKind.toString timer.kind)
                        , Element.text "Timer is running"
                        , Element.text (remaining |> RemainingSeconds.toString)
                        ]

                Nothing ->
                    Element.text "No active timer"

        Nothing ->
            Element.text "No active timer"
