module Transactions exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Http
import Task
import String
import Date
import Api exposing (Transaction, fetchTransactions)


type alias Model =
    { transactions : List Transaction
    }


init publicToken =
    let
        model =
            { transactions = []
            }
    in
        ( model, cmdToFetch publicToken )


type Msg
    = FetchSuccess (List Transaction)
    | FetchFailure Http.Error


update msg model =
    case msg of
        FetchSuccess transactions ->
            ( { model | transactions = transactions }, Cmd.none )

        FetchFailure err ->
            let
                _ =
                    Debug.log "FetchFailure" err
            in
                ( model, Cmd.none )


cmdToFetch publicToken =
    Task.perform FetchFailure FetchSuccess (Api.fetchTransactions publicToken)


view : Model -> Html Msg
view model =
    div []
        (List.map transactionView model.transactions)


transactionView : Transaction -> Html Msg
transactionView transaction =
    let
        displayCategory maybeCategory =
            transaction.category `Maybe.andThen` (\c -> Just (String.join ", " c)) |> Maybe.withDefault ""

        displayDate date =
            [ toString (Date.day date)
            , toString (Date.month date)
            , toString (Date.year date)
            ]
                |> String.join (" ")
    in
        div [ class "transaction" ]
            [ div [ class "transaction__amount" ] [ text ("$" ++ toString transaction.amount) ]
            , div [ class "transaction__heading" ] [ text transaction.name ]
            , div []
                [ text (displayDate transaction.date)
                , text " · "
                , text (displayCategory transaction.category)
                ]
            ]
