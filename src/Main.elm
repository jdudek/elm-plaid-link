module Main exposing (main)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)
import Html.App as App
import Plaid
import Accounts


main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { loaded : Bool
    , accounts : Maybe Accounts.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { loaded = False
            , accounts = Nothing
            }
    in
        ( model, Cmd.none )


type Msg
    = NoOp
    | PlaidLinkClicked
    | Plaid Plaid.Msg
    | Accounts Accounts.Msg


update msg model =
    case msg of
        PlaidLinkClicked ->
            ( model, Plaid.cmdToOpen )

        Plaid (Plaid.Loaded) ->
            ( { model | loaded = True }, Cmd.none )

        Plaid (Plaid.Exited) ->
            ( model, Cmd.none )

        Plaid (Plaid.Success publicToken meta) ->
            let
                ( accountsModel, accountsCmd ) =
                    Accounts.init publicToken
            in
                ( { model | accounts = Just accountsModel }, Cmd.map Accounts accountsCmd )

        Plaid (Plaid.Error err) ->
            let
                _ =
                    Debug.log "Plaid.Error" err
            in
                ( model, Cmd.none )

        Accounts accountsMsg ->
            case model.accounts of
                Just accounts ->
                    let
                        ( accountsModel, accountsCmd ) =
                            Accounts.update accountsMsg accounts
                    in
                        ( { model | accounts = Just accountsModel }, accountsCmd )

                Nothing ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map Plaid Plaid.subscriptions


view : Model -> Html Msg
view model =
    case model.accounts of
        Just accounts ->
            App.map Accounts (Accounts.view accounts)

        Nothing ->
            buttonToPlaidLink model


buttonToPlaidLink model =
    button
        [ disabled (not model.loaded)
        , onClick PlaidLinkClicked
        ]
        [ text "Link your bank account" ]
