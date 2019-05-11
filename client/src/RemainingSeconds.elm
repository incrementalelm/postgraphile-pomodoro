module RemainingSeconds exposing (RemainingSeconds, between, toString)

import Time


between : { now : Time.Posix, timerCreated : Time.Posix, timerDurationMinutes : Int } -> Maybe RemainingSeconds
between { now, timerCreated, timerDurationMinutes } =
    let
        timerMillis =
            timerDurationMinutes * 60 * 1000
    in
    (((Time.posixToMillis timerCreated + timerMillis) - Time.posixToMillis now)
        // 1000
    )
        |> remainingSeconds


remainingSeconds : Int -> Maybe RemainingSeconds
remainingSeconds seconds =
    if seconds > 0 then
        seconds |> RemainingSeconds |> Just

    else
        Nothing


type RemainingSeconds
    = RemainingSeconds Int


toString : RemainingSeconds -> String
toString (RemainingSeconds seconds) =
    [ seconds
        // 60
        |> String.fromInt
    , seconds
        |> modBy 60
        |> String.fromInt
        |> String.padLeft 2 '0'
    ]
        |> String.join ":"
