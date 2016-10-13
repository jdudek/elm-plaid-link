module Accounts exposing (..)

import Html exposing (Html, div, text)
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
        [ text (toString model.accounts)
        ]
