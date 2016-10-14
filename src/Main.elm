module Main exposing (main)

import Html exposing (Html, div, text, button, h1, header, p, hr)
import Html.Attributes exposing (disabled, class)
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
    div [ class "container page-container" ]
        [ header [ class "page-header" ]
            [ h1 [] [ text "elm-plaid-link" ]
            , div [ class "secondary-heading secondary-heading--is-muted" ]
                [ text "A sample integration of Plaid Link in Elm" ]
            ]
        , mainView model
        ]


mainView model =
    case model.accounts of
        Just accounts ->
            App.map Accounts (Accounts.view accounts)

        Nothing ->
            buttonView model


buttonView model =
    div []
        [ p [] [ text "Plaid Link is a drop-in module that offers a secure, elegant authentication flow for all institutions supported by Plaid." ]
        , p [] [ text "This demo allows you to connect a bank account using Plaid Link, and collect account-level data from Plaid Auth. You can do this using the Plaid test credentials displayed at the bottom of the Plaid Link screen." ]
        , hr [ class "hr" ] []
        , buttonToPlaidLink model
        ]


buttonToPlaidLink model =
    button
        [ disabled (not model.loaded)
        , class "button button--is-default"
        , onClick PlaidLinkClicked
        ]
        [ text "Link your bank account" ]
