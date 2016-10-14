module Api exposing (Account, fetchAccounts)

import Http
import Json.Decode as Decode exposing (Decoder, object1, object2, object5, (:=), string, float, list)
import Json.Encode as Json
import Task exposing (Task)


type alias Account =
    { id : String
    , balance : { available : Float, current : Float }
    , meta : { name : String }
    , numbers : Maybe { routing : String, account : String }
    , accountType : String
    }


fetchAccounts : String -> Task Http.Error (List Account)
fetchAccounts publicToken =
    let
        url =
            Http.url "/accounts" [ ("public_token", publicToken) ]
    in
        Http.get accountsDecoder url


accountsDecoder : Decoder (List Account)
accountsDecoder =
    Decode.at [ "accounts" ] (list accountDecoder)


accountDecoder : Decoder Account
accountDecoder =
    let
        balanceDecoder =
            object2 (\a c -> { available = a, current = c })
                ("available" := float)
                ("current" := float)

        metaDecoder =
            object1 (\n -> { name = n })
                ("name" := string)

        numbersDecoder =
            object2 (\r a -> { routing = r, account = a })
                ("routing" := string)
                ("account" := string)
    in
        object5 Account
            ("_id" := string)
            ("balance" := balanceDecoder)
            ("meta" := metaDecoder)
            (Decode.maybe ("numbers" := numbersDecoder))
            ("type" := string)
