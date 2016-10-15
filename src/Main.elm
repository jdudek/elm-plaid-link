module Main exposing (main)

import Html exposing (Html, div, text, button, h1, header, p, hr, ul, li, span)
import Html.Attributes exposing (disabled, class)
import Html.Events exposing (onClick)
import Html.App as App
import Plaid
import Accounts
import Transactions


main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { loaded : Bool
    , publicToken : String
    , pane : Maybe Pane
    }


type Pane
    = AccountsPane Accounts.Model
    | TransactionsPane Transactions.Model


init : ( Model, Cmd Msg )
init =
    let
        model =
            { loaded = False
            , publicToken = ""
            , pane = Nothing
            }
    in
        ( model, Cmd.none )


type Msg
    = PlaidLinkClicked
    | Plaid Plaid.Msg
    | Accounts Accounts.Msg
    | Transactions Transactions.Msg
    | ShowAccounts
    | ShowTransactions


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

                model' =
                    { model
                        | publicToken = publicToken
                        , pane = Just (AccountsPane accountsModel)
                    }
            in
                ( model', Cmd.map Accounts accountsCmd )

        Plaid (Plaid.Error err) ->
            let
                _ =
                    Debug.log "Plaid.Error" err
            in
                ( model, Cmd.none )

        ShowAccounts ->
            let
                ( accountsModel, accountsCmd ) =
                    Accounts.init model.publicToken

                model' =
                    { model | pane = Just (AccountsPane accountsModel) }
            in
                ( model', Cmd.map Accounts accountsCmd )

        ShowTransactions ->
            let
                ( transactionsModel, transactionsCmd ) =
                    Transactions.init model.publicToken

                model' =
                    { model | pane = Just (TransactionsPane transactionsModel) }
            in
                ( model', Cmd.map Transactions transactionsCmd )

        _ ->
            case ( model.pane, msg ) of
                ( Just (AccountsPane accountsModel), Accounts accountsMsg ) ->
                    let
                        ( accountsModel', accountsCmd ) =
                            Accounts.update accountsMsg accountsModel

                        model' =
                            { model | pane = Just (AccountsPane accountsModel') }
                    in
                        ( model', accountsCmd )

                ( Just (TransactionsPane transactionsModel), Transactions transactionsMsg ) ->
                    let
                        ( transactionsModel', transactionsCmd ) =
                            Transactions.update transactionsMsg transactionsModel

                        model' =
                            { model | pane = Just (TransactionsPane transactionsModel') }
                    in
                        ( model', transactionsCmd )

                _ ->
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


mainView : Model -> Html Msg
mainView model =
    let
        withNavigation view =
            div [ class "grid page-grid" ]
                [ div [ class "grid__column grid__column--is-three-columns" ] [ navigationView ]
                , div [ class "grid__column grid__column--is-nine-columns" ] [ view ]
                ]
    in
        case model.pane of
            Just (AccountsPane accounts) ->
                App.map Accounts (Accounts.view accounts) |> withNavigation

            Just (TransactionsPane transactions) ->
                App.map Transactions (Transactions.view transactions) |> withNavigation

            Nothing ->
                buttonView model


navigationView : Html Msg
navigationView =
    let
        itemView msg caption =
            li [ class "vertical-navigation__item" ]
                [ span [ class "anchor vertical-navigation__anchor", onClick msg ] [ text caption ] ]
    in
        ul [ class "vertical-navigation" ]
            [ itemView ShowAccounts "Accounts"
            , itemView ShowTransactions "Transactions"
            ]


buttonView : Model -> Html Msg
buttonView model =
    div []
        [ p [] [ text "Plaid Link is a drop-in module that offers a secure, elegant authentication flow for all institutions supported by Plaid." ]
        , p [] [ text "This demo allows you to connect a bank account using Plaid Link, and collect account-level data from Plaid Auth. You can do this using the Plaid test credentials displayed at the bottom of the Plaid Link screen." ]
        , hr [ class "hr" ] []
        , buttonToPlaidLink model
        ]


buttonToPlaidLink : Model -> Html Msg
buttonToPlaidLink model =
    button
        [ class "button button--is-default"
        , onClick PlaidLinkClicked
        ]
        [ text "Link your bank account" ]
