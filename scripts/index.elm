port module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- import Http exposing (..)
-- import Json.Decode as Json exposing ((:=))
-- import Task


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { distanceClusters : Clusters
    , taxonomicClusters : Clusters
    , parameters : List Parameters
    , title : String
    }


type alias Parameters =
    { pvalue : Float
    , distance : Float
    , kmer : Int
    , sketch : Int
    }


type alias Clusters =
    List Cluster


type alias Cluster =
    { id : String, data : List ClusterObject, name : Maybe String }


type alias ClusterObject =
    { name : Maybe String, id : String, count : Int }


init : ( Model, Cmd Msg )
init =
    ( Model [] [] [] "", Cmd.none )



-- UPDATE


type Msg
    = TaxonomicCluster Clusters
    | DistanceCluster Clusters
    | DataClusters Model


port draw : Clusters -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataClusters m ->
            ( Model m.distanceClusters m.taxonomicClusters m.parameters "Distance Clusters", draw m.distanceClusters )

        TaxonomicCluster clusters ->
            let
                newModel =
                    { model |
                          title = "Taxonomic clusters"
                    }
            in
                ( newModel, draw clusters)

        DistanceCluster clusters ->
            let
                newModel =
                    { model |
                          title = "Distance Clusters"
                    }
            in
                ( newModel, draw clusters)




-- SUBSCRIPTIONS


port dataClusters : (Model -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    dataClusters DataClusters



-- VIEW


view model =
    div
        [ classList
            [ ( "row", True )
            ]
        ]
        [ parameters model.parameters
        , button [ onClick (DistanceCluster model.distanceClusters) ] [ text "Distance Clusters" ]
        , button [ onClick (TaxonomicCluster model.taxonomicClusters) ] [ text "Taxonomic Clusters" ]
        , div [] [h4 [] [text model.title]]
        ]


parameters params =
    let
        row param =
            Html.tr
                []
                [ Html.td [] [ text (toString (param.kmer)) ]
                , Html.td [] [ text (toString (param.sketch)) ]
                , Html.td [] [ text (toString (param.pvalue)) ]
                , Html.td [] [ text (toString (param.distance)) ]
                ]
    in
        Html.table
            [ class "table table-condensed" ]
            [ thead []
                [ tr []
                    [ td [] [ text "Kmer size" ]
                    , td [] [ text "Number Sketches" ]
                    , td [] [ text "P-value Threshold" ]
                    , td [] [ text "Distance Threshold" ]
                    ]
                ]
            , tbody [] (List.map row params)
            ]
