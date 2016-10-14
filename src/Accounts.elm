module Accounts exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Http
import Task
import Api exposing (Account, fetchAccounts)


type alias Model =
    { publicToken : String
    , accounts : List Account
    }


init publicToken =
    let
        model =
            { publicToken = publicToken
            , accounts = []
            }
    in
        ( model, cmdToFetch model )


type Msg
    = NoOp
    | FetchSuccess (List Account)
    | FetchFailure Http.Error


update msg model =
    case msg of
        FetchSuccess accounts ->
            ( { model | accounts = accounts }, Cmd.none )

        FetchFailure err ->
            let
                _ =
                    Debug.log "FetchFailure" err
            in
                ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


cmdToFetch model =
    Task.perform FetchFailure FetchSuccess (Api.fetchAccounts model.publicToken)


view : Model -> Html Msg
view model =
    div []
        (List.map accountView model.accounts)


accountView : Account -> Html Msg
accountView account =
    let
        numberLine show =
            case account.numbers of
                Just numbers ->
                    div [] [ text (show numbers) ]

                Nothing ->
                    text ""
    in
        div [ class "account" ]
            [ div [ class "account__heading" ] [ text account.meta.name ]
            , numberLine (\numbers -> "Account: " ++ numbers.account)
            , numberLine (\numbers -> "Routing: " ++ numbers.routing)
            ]
