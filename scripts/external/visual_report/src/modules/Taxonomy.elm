module Taxonomy exposing (..)

import Taxonomy.Rank as Rank exposing (..)
--import Html exposing (..)
import String exposing (..)
import Json.Decode as Json exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode exposing (..)


type Taxonomy
    = Empty
    | Taxonomy TaxonomyInfo


type alias TaxonomyInfo =
    { oid : Maybe Rank.Rank
    , strain : Maybe Rank.Rank
    , species : Maybe Rank.Rank
    , genus : Maybe Rank.Rank
    , family : Maybe Rank.Rank
    , order : Maybe Rank.Rank
    , class_ : Maybe Rank.Rank
    , phylum : Maybe Rank.Rank
    }


constructTaxonomy : TaxonomyInfo -> Result a Taxonomy
constructTaxonomy taxoInfo =
    Ok (Taxonomy taxoInfo)


decodeTaxonomy : Json.Decoder Taxonomy
decodeTaxonomy =
    Json.customDecoder decodeTaxonomyInfo constructTaxonomy


decodeTaxonomyInfo : Decoder TaxonomyInfo
decodeTaxonomyInfo =
    decode TaxonomyInfo
        |> Json.Decode.Pipeline.optional "oid" (Rank.decodeMaybeRank "oid") Nothing
        |> Json.Decode.Pipeline.optional "strain" (Rank.decodeMaybeRank "strain") Nothing
        |> Json.Decode.Pipeline.optional "species" (Rank.decodeMaybeRank "species") Nothing
        |> Json.Decode.Pipeline.optional "genus" (Rank.decodeMaybeRank "genus") (Just (Rank.Genus Nothing))
        |> Json.Decode.Pipeline.optional "family" (Rank.decodeMaybeRank "family") Nothing
        |> Json.Decode.Pipeline.optional "order" (Rank.decodeMaybeRank "order") Nothing
        |> Json.Decode.Pipeline.optional "class_" (Rank.decodeMaybeRank "class_") Nothing
        |> Json.Decode.Pipeline.optional "phylum" (Rank.decodeMaybeRank "phylum") Nothing


extractRank : String -> TaxonomyInfo -> Maybe Rank
extractRank rankName taxoInfo =
    let
        lowerRankName =
            String.toLower rankName
    in
        case lowerRankName of
            "oid" ->
                .oid taxoInfo

            "strain" ->
                .strain taxoInfo

            "species" ->
                .species taxoInfo

            "genus" ->
                .genus taxoInfo

            "family" ->
                .family taxoInfo
                    
            "order" ->
                .order taxoInfo
                    
            "class" ->
               taxoInfo.class_
                    
            "phylum" ->
                .phylum taxoInfo

            _ ->
                Nothing


encodeTaxonomy : Taxonomy -> Json.Encode.Value
encodeTaxonomy taxonomy =
    case taxonomy of
        Empty ->
            Json.Encode.null

        Taxonomy taxoInfo ->
            encodeTaxonomyInfo taxoInfo

                
encodeTaxonomyInfo : TaxonomyInfo -> Json.Encode.Value
encodeTaxonomyInfo taxoInfo =
    let
        typeNameToValue typeName =
            ( typeName, Rank.encodeMaybeRank (extractRank typeName taxoInfo) )

        listEncode =
            List.map typeNameToValue Rank.getAllRankString
    in
        Json.Encode.object listEncode


taxonomyToString : Result a Taxonomy -> String
taxonomyToString taxonomy =
    case taxonomy of
        Ok taxo ->
            toString (encodeTaxonomy taxo)

        Err error ->
            toString error


-- main : Html a
-- main =
--     let
--         taxo =
--             Json.decodeString decodeTaxonomy """ { "oid" : { "name" : "oid_rank", "taxid" : "" } } """

--         taxo2 =
--             Json.decodeString decodeTaxonomy """ { "species" : { "name" : "oid_rank", "taxid" : "" } } """

--         list =
--             [ div [] [ text (toString taxo) ]
--             , div [] [ text ("encode : " ++ (taxonomyToString taxo)) ]
--             , div [] [ text (toString taxo2) ]
--             , div [] [ text ("encode : " ++ (taxonomyToString taxo2)) ]
--             ]
--     in
--         div [] list
