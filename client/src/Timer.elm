module Timer exposing (Timer)

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
