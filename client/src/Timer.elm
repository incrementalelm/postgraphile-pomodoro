module Timer exposing (Timer, selection)

import Api.Enum.TimerKind
import Api.Object
import Api.Object.Timer
import Api.Query as Query
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
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
