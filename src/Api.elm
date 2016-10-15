module Api exposing (Account, fetchAccounts, Transaction, fetchTransactions)

import Http
import Json.Decode as Decode exposing (Decoder, object1, object2, object5, object8, (:=), string, float, list, bool)
import Json.Encode as Json
import Task exposing (Task)
import Date exposing (Date)


type alias Account =
    { id : String
    , balance : { available : Float, current : Float }
    , meta : { name : String }
    , numbers : Maybe { routing : String, account : String }
    , accountType : String
    }


type alias Transaction =
    { id : String
    , accountId : String
    , amount : Float
    , date : Date
    , name : String
    , meta : { location : Maybe Location }
    , pending : Bool
    , category : Maybe (List String)
    }


type alias Location =
    { city : String
    , state : String
    , address : Maybe String
    , zip : Maybe String
    , coordinates : Maybe { lat : Float, lon : Float }
    }


fetchAccounts : String -> Task Http.Error (List Account)
fetchAccounts publicToken =
    let
        url =
            Http.url "/accounts" [ ( "public_token", publicToken ) ]
    in
        Http.get accountsDecoder url


fetchTransactions : String -> Task Http.Error (List Transaction)
fetchTransactions publicToken =
    let
        url =
            Http.url "/transactions" [ ( "public_token", publicToken ) ]
    in
        Http.get transactionsDecoder url


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


transactionsDecoder : Decoder (List Transaction)
transactionsDecoder =
    Decode.at [ "transactions" ] (list transactionDecoder)


transactionDecoder : Decoder Transaction
transactionDecoder =
    let
        dateDecoder =
            string
                `Decode.andThen`
                    \s ->
                        case Date.fromString s of
                            Ok d ->
                                Decode.succeed d

                            Err e ->
                                Decode.fail (s ++ " is not a date")

        metaDecoder =
            object1 (\l -> { location = l })
                (Decode.maybe ("location" := locationDecoder))

        locationDecoder =
            object5 Location
                ("city" := string)
                ("state" := string)
                (Decode.maybe ("address" := string))
                (Decode.maybe ("zip" := string))
                (Decode.maybe ("coordinates" := coordinatesDecoder))

        coordinatesDecoder =
            object2 (\lat lon -> { lat = lat, lon = lon })
                ("lat" := float)
                ("lon" := float)
    in
        object8 Transaction
            ("_id" := string)
            ("_account" := string)
            ("amount" := float)
            ("date" := dateDecoder)
            ("name" := string)
            ("meta" := metaDecoder)
            ("pending" := bool)
            (Decode.maybe ("category" := list string))
