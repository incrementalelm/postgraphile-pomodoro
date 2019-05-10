module Scalar exposing (Datetime, codecs)

import Api.Scalar exposing (Datetime(..), defaultCodecs)
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Time


type alias Datetime =
    Time.Posix


codecs : Api.Scalar.Codecs Time.Posix
codecs =
    Api.Scalar.defineCodecs
        { codecDatetime =
            { encoder = \posixTime -> Encode.int (Time.toMillis Time.utc posixTime)
            , decoder = Iso8601.decoder
            }
        }
