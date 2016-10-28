module Taxonomy.Rank exposing (..)

import Html exposing (..)
import String exposing (..)
import Json.Decode as Json exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode exposing (..)


--import Task exposing (..)


type Rank
    = Oid (Maybe RankInfo)
    | Strain (Maybe RankInfo)
    | Species (Maybe RankInfo)
    | Genus (Maybe RankInfo)
    | Family (Maybe RankInfo)
    | Order (Maybe RankInfo)
    | Class (Maybe RankInfo)
    | Phylum (Maybe RankInfo)


-- type Ranks
--     = Empty
--     | Ranks (List Rank)
    
type alias RankInfo =
    { name : Maybe String
    , taxid : Maybe Int
    }

getAllRankString : List String
getAllRankString =
    getListRankString
    [ Oid Nothing
    , Strain Nothing
    , Species Nothing
    , Genus Nothing
    , Family Nothing
    , Order Nothing
    , Class Nothing
    , Phylum Nothing
    ]
    
getListRankString : List Rank -> List String
getListRankString ranks =
    List.map (\rank -> typeOfRank rank ) ranks



        
maybeRankOfString : String -> Maybe RankInfo -> Maybe Rank
maybeRankOfString rankStr rankInfo =
    let
        lowerStr =
            String.toLower rankStr
    in
        case lowerStr of
            "oid" ->
                Just (Oid rankInfo)

            "strain" ->
                Just (Strain rankInfo)

            "species" ->
                Just (Species rankInfo)

            "genus" ->
                Just (Genus rankInfo)

            "family" ->
                Just (Family rankInfo)

            "order" ->
                Just (Order rankInfo)

            "class" ->
                Just (Class rankInfo)

            "phylum" ->
                Just (Phylum rankInfo)

            _ ->
                Nothing

resultRankOfMaybeRankInfo : String -> Maybe RankInfo -> Result String Rank
resultRankOfMaybeRankInfo rankStr rankInfo  =
    let
        rank = maybeRankOfString rankStr rankInfo
    in
        Result.fromMaybe (rankStr ++ " is not a rank") rank


                    
resultRankOfRankInfo : String -> RankInfo -> Result String Rank
resultRankOfRankInfo rankStr rankInfo  =
    resultRankOfMaybeRankInfo rankStr (Just rankInfo)
                
typeOfRank : Rank -> String
typeOfRank rank =
    case rank of
        Oid rankInfo ->
            "oid"

        Strain rankInfo ->
            "strain"

        Species rankInfo ->
            "species"

        Genus rankInfo ->
            "genus"

        Family rankInfo ->
            "family"

        Order rankInfo ->
            "order"

        Class rankInfo ->
            "class"

        Phylum rankInfo ->
            "phylum"


taxidOfRank : Rank -> Maybe Int
taxidOfRank rank =
    case rank of
        Oid rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.taxid

        Strain rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.taxid

        Species rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.taxid

        Genus rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.taxid

        Family rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.taxid

        Order rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.taxid

        Class rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.taxid

        Phylum rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.taxid


nameOfRank : Rank -> Maybe String
nameOfRank rank =
    case rank of
        Oid rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.name

        Strain rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.name

        Species rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.name

        Genus rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.name

        Family rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.name

        Order rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.name

        Class rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.name

        Phylum rankInfo ->
            case rankInfo of
                Nothing ->
                    Nothing

                Just rankInfo ->
                    rankInfo.name


toValidTaxid : String -> Decoder (Maybe Int)
toValidTaxid taxid =
    if taxid == "" then
        Json.succeed Nothing
    else
        case (String.toInt taxid) of
            Ok taxidInt ->
                Json.map Just Json.int

            Err error ->
                Json.fail (taxid ++ " is not a valid taxid")


decodeTaxid : Decoder (Maybe Int)
decodeTaxid =
    Json.string `Json.andThen` toValidTaxid


taxid : Json.Decoder (Maybe Int)
taxid =
    Json.oneOf
        [ Json.map Just Json.int
        , decodeTaxid
        , Json.null Nothing
        ]


{-|
-}
decodeMaybeRank : String -> Decoder (Maybe Rank)
decodeMaybeRank rankName =
    (Json.Decode.Pipeline.nullable (decodeRank rankName))




        
decodeRank : String -> Decoder Rank
decodeRank rank =
    let
        lowerRank =
            String.toLower rank
    in
        Json.customDecoder decodeRankInfo (resultRankOfRankInfo lowerRank)



--("name" := Json.string) `Json.andThen` rankInfo


decodeRankInfo : Decoder RankInfo
decodeRankInfo =
    decode RankInfo
        |> Json.Decode.Pipeline.optional "name" (Json.Decode.Pipeline.nullable Json.string) Nothing
        |> Json.Decode.Pipeline.optional "taxid" taxid Nothing



           
encodeRank : Rank -> Json.Encode.Value
encodeRank rank =
    let
        taxid =
            case (taxidOfRank rank) of
                Nothing ->
                    Json.Encode.null

                Just id ->
                    Json.Encode.int id

        name =
            case (nameOfRank rank) of
                Nothing ->
                    Json.Encode.null

                Just n ->
                    Json.Encode.string n
    in
        Json.Encode.object
            [ ( "name", name )
            , ( "taxid", taxid )
            ]

            
encodeMaybeRank : Maybe Rank -> Json.Encode.Value
encodeMaybeRank rank =
    case rank of
        Nothing ->
            Json.Encode.null

        Just rank ->
            encodeRank rank

rankToString : Result a Rank -> String
rankToString rank =
    case rank of
        Ok value ->
            toString (encodeRank value)

        Err error ->
            toString error


main : Html a
main =
    let
        res =
            Json.decodeString (decodeRank "species") """{ "name" : null, "taxid" : null }"""

        res2 =
            Json.decodeString (decodeRank "Phylum") """ { "name" : "Prote", "taxid" : 0 }"""

        res3 =
            Json.decodeString (decodeRank "foo") """ { "name" : "toto", "taxid" : null }"""

        res4 =
            Json.decodeString (decodeRank "species") "null"

        res5 =
            Json.decodeString (decodeRank "species") """ {"name": "not valid taxid", "taxid":"rere" } """

        res6 =
            Json.decodeString (decodeRank "species") """ { "name" : "toto", "taxid" : "" }"""

        res7 =
            Json.decodeString (decodeRank "species") """ { "name" : "toto", "taxid" : null }"""

        res8 =
            Json.decodeString (decodeRank "species") """ { "taxid" : 23 }"""
                
        
        list =
            [ div []
                [ text
                    (toString
                        (Phylum
                            (Just
                                (RankInfo
                                    (Just "Proteo")
                                    (Just 10)
                                )
                            )
                        )
                    )
                ]
            , div [] [ text (toString res) ]
            , div [] [ text ("encode : " ++ (rankToString res)) ]
            , div [] [ text (toString res2) ]
            , div [] [ text ("encode : " ++ (rankToString res2)) ]
            , div [] [ text (toString res3) ]
            , div [] [ text ("encode : " ++ (rankToString res3)) ]
            , div [] [ text (toString res4) ]
            , div [] [ text ("encode : " ++ (rankToString res4)) ]
            , div [] [ text (toString res5) ]
            , div [] [ text ("encode : " ++ (rankToString res5)) ]
            , div [] [ text (toString res6) ]
            , div [] [ text ("encode : " ++ (rankToString res6)) ]
            , div [] [ text (toString res7) ]
            , div [] [ text ("encode : " ++ (rankToString res7)) ]
            , div [] [ text (toString res8) ]
            , div [] [ text ("encode : " ++ (rankToString res8)) ]

            ]
    in
        div [] list
