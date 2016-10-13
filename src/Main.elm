module Main exposing (main)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)
import Html.App as App
import Plaid


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
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { loaded = False
            , publicToken = ""
            }
    in
        ( model, Cmd.none )


type Msg
    = NoOp
    | PlaidLinkClicked
    | Plaid Plaid.Msg


update msg model =
    case msg of
        PlaidLinkClicked ->
            ( model, Plaid.cmdToOpen )

        Plaid (Plaid.Loaded) ->
            ( { model | loaded = True }, Cmd.none )

        Plaid (Plaid.Exited) ->
            ( model, Cmd.none )

        Plaid (Plaid.Success publicToken meta) ->
            ( { model | publicToken = publicToken }, Cmd.none )

        Plaid (Plaid.Error err) ->
            let
                _ =
                    Debug.log "Plaid.Error" err
            in
                ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map Plaid Plaid.subscriptions


view : Model -> Html Msg
view model =
    div []
        [ buttonToPlaidLink model
        , text model.publicToken
        ]


buttonToPlaidLink model =
    button
        [ disabled (not model.loaded)
        , onClick PlaidLinkClicked
        ]
        [ text "Link your bank account" ]
