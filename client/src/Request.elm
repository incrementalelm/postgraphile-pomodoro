module Request exposing (Response, mutation, query)

import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Http
import RemoteData exposing (RemoteData)


type alias Response data =
    RemoteData (Graphql.Http.RawError () Http.Error) data


endpoint : String
endpoint =
    "http://localhost:5000/graphql"


query :
    (Response decodesTo -> msg)
    -> SelectionSet decodesTo RootQuery
    -> Cmd msg
query msgConstructor querySelection =
    querySelection
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.send
            (\result ->
                result
                    |> Graphql.Http.discardParsedErrorData
                    |> Graphql.Http.withSimpleHttpError
                    |> RemoteData.fromResult
                    |> msgConstructor
            )


mutation :
    (Response decodesTo -> msg)
    -> SelectionSet decodesTo RootMutation
    -> Cmd msg
mutation msgConstructor querySelection =
    querySelection
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.send
            (\result ->
                result
                    |> Graphql.Http.discardParsedErrorData
                    |> Graphql.Http.withSimpleHttpError
                    |> RemoteData.fromResult
                    |> msgConstructor
            )
