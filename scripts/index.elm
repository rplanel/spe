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
    , displayedClusters : Clusters
    , parameters : List Parameters
    , title : String
    , min : Int
    , max : Int
    , numberOfClusters : Int
    , histogramData : List Int
    }


type alias Range =
    { min : Int
    , max : Int
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
    ( Model [] [] [] [] "" 0 1 0 [0], Cmd.none )



-- UPDATE


type Msg
    = TaxonomicCluster
    | DistanceCluster
    | DataClusters Model
    | SliderChange Range


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataClusters m ->
            ( Model
                m.distanceClusters
                m.taxonomicClusters
                m.displayedClusters
                m.parameters
                "Distance Clusters"
                m.min
                m.max
                (List.length m.displayedClusters)
                m.histogramData
            , draw (m.displayedClusters, m.histogramData)
            )

        TaxonomicCluster ->
            let
                filteredClusters =
                    List.filter
                        (betweenRange model.min model.max)
                        model.taxonomicClusters
                            
                (min, max) = (List.foldr minMax (0,0) model.taxonomicClusters)
                             
                newModel =
                    { model
                        | title = "Taxonomic clusters"
                        , displayedClusters = model.taxonomicClusters
                        , min = min
                        , max = max
                        , numberOfClusters = List.length filteredClusters
                        , histogramData    = List.map (\n -> List.length n.data) filteredClusters
                    }


            in
                ( newModel, Cmd.batch
                    [ sliderRange [min, max]
                    , draw (filteredClusters, newModel.histogramData)
                    ]
                )

        DistanceCluster ->
            let
                filteredClusters =
                    List.filter
                        (betweenRange model.min model.max)
                        model.distanceClusters


                (min, max) = (List.foldr minMax (0,0) model.distanceClusters)
                             
                newModel =
                    { model
                        | title = "Distance Clusters"
                        , displayedClusters = model.distanceClusters
                        , min = min
                        , max = max
                        , numberOfClusters = List.length filteredClusters
                        , histogramData    = List.map (\n -> List.length n.data) filteredClusters
                    }
            in
                ( newModel, Cmd.batch
                      [ sliderRange [min, max]
                      , draw (filteredClusters, newModel.histogramData)
                      ]
                )

        SliderChange range ->
            let
                filteredClusters =
                    List.filter
                        (betweenRange range.min range.max)
                        model.displayedClusters

                newModel =
                    { model
                        | min = range.min
                        , max = range.max
                        , numberOfClusters = List.length filteredClusters
                        , histogramData    = List.map (\n -> List.length n.data) filteredClusters
                    }
            in
                ( newModel
                , Cmd.batch
                    [ draw (filteredClusters, newModel.histogramData)
                    ]
                )



-- SUBSCRIPTIONS


port draw : (Clusters, List Int) -> Cmd msg
port sliderRange : (List Int) -> Cmd msg

port dataClusters : (Model -> msg) -> Sub msg
port sliderChange : (Range -> msg) -> Sub msg



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ dataClusters DataClusters
        , sliderChange SliderChange
        ]



-- VIEW


view model =
    div
        [ classList
            [ ( "row", True )
            ]
        ]
        [ parameters model.parameters
        , button [ onClick (DistanceCluster) ] [ text "Distance Clusters" ]
        , button [ onClick (TaxonomicCluster) ] [ text "Taxonomic Clusters" ]
        , div
            []
            [ h4 [] [ text (model.title ++ " ("++ toString model.numberOfClusters ++ ")") ] ]
        ]


parameters :
    List { e | distance : a, kmer : b, pvalue : c, sketch : d }
    -> Html f
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


betweenRange min max cluster =
    List.length cluster.data >= min && List.length cluster.data <= max


minMax cluster range =
    let
        currentLength = List.length cluster.data
        (min,max) = range
    in
        (Basics.min currentLength min, Basics.max currentLength max)
