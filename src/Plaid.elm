port module Plaid exposing (Msg(..), cmdToOpen, subscriptions)

import Json.Decode as Decode exposing ((:=), Decoder, decodeValue)
import Json.Encode as Json


port openPlaid : () -> Cmd msg


port onPlaidLoad : (() -> msg) -> Sub msg


port onPlaidSuccess : (( String, Json.Value ) -> msg) -> Sub msg


port onPlaidExit : (() -> msg) -> Sub msg


type Msg
    = Loaded
    | Exited
    | Success String Metadata
    | Error String


type alias Metadata =
    { institutionName : String
    , institutionType : String
    , accountId : Maybe String
    }


cmdToOpen : Cmd msg
cmdToOpen =
    openPlaid ()


subscriptions : Sub Msg
subscriptions =
    let
        handleOnSuccess ( publicToken, json ) =
            case decodeValue metadataDecoder json of
                Ok metadata ->
                    Success publicToken metadata

                Err err ->
                    Error err
    in
        Sub.batch
            [ onPlaidLoad (\_ -> Loaded)
            , onPlaidExit (\_ -> Exited)
            , onPlaidSuccess handleOnSuccess
            ]


metadataDecoder : Decoder Metadata
metadataDecoder =
    let
        decoder =
            Decode.object2 (,)
                ("institution"
                    := Decode.object2 (,)
                        ("name" := Decode.string)
                        ("type" := Decode.string)
                )
                (Decode.maybe ("account_id" := Decode.string))

        flatten ( ( institutionName, institutionType ), accountId ) =
            Decode.succeed
                { institutionName = institutionName
                , institutionType = institutionType
                , accountId = accountId
                }
    in
        decoder `Decode.andThen` flatten
