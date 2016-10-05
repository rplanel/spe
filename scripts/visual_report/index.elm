port module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex


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
    , pattern : String
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
    ( Model [] [] [] [] "" 0 1 0 [ 0 ] "", Cmd.none )



-- UPDATE


type Msg
    = TaxonomicCluster
    | DistanceCluster
    | DataClusters Model
    | SliderChange Range
    | FilterClusters String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataClusters m ->
            let
                ( min, max ) =
                    getMinMaxClusterSize m.distanceClusters

                filteredClusters =
                    m.distanceClusters
                        |> List.filter (hasPattern model.pattern)
                        |> preprocessCluster min max

                histogramData =
                    (List.map (\n -> List.length n.data) filteredClusters)
            in
                ( Model
                    m.distanceClusters
                    m.taxonomicClusters
                    m.displayedClusters
                    m.parameters
                    "Distance Clusters"
                    min
                    max
                    (List.length filteredClusters)
                    histogramData
                    m.pattern
                , Cmd.batch
                    [ sliderRange [ min, max ]
                    , sliderValue [ min, max ]
                    , draw ( filteredClusters, histogramData )
                    ]
                )

        TaxonomicCluster ->
            let
                filteredClusters =
                    model.taxonomicClusters
                        |> List.filter (hasPattern model.pattern)
                        |> preprocessCluster min max

                ( min, max ) =
                    getMinMaxClusterSize model.taxonomicClusters

                newModel =
                    { model
                        | title = "Taxonomic clusters"
                        , displayedClusters =
                            model.taxonomicClusters
                        , numberOfClusters = List.length filteredClusters
                        , histogramData = List.map (\n -> List.length n.data) filteredClusters
                    }
            in
                ( newModel
                , Cmd.batch
                    [ sliderRange [ min, max ]
                    , sliderValue [ min, max ]
                    , draw ( filteredClusters, newModel.histogramData )
                    ]
                )

        -- DISTANCE
        DistanceCluster ->
            let
                filteredClusters =
                    model.distanceClusters
                        |> List.filter (hasPattern model.pattern)
                        |> preprocessCluster min max

                ( min, max ) =
                    getMinMaxClusterSize model.distanceClusters

                newModel =
                    { model
                        | title = "Distance Clusters"
                        , displayedClusters =
                            model.distanceClusters
                        , numberOfClusters = List.length filteredClusters
                        , histogramData = List.map (\n -> List.length n.data) filteredClusters
                    }
            in
                ( newModel
                , Cmd.batch
                    [ sliderRange [ min, max ]
                    , sliderValue [ min, max ]
                    , draw ( filteredClusters, newModel.histogramData )
                    ]
                )

        SliderChange range ->
            let
                filteredClusters =
                    model.displayedClusters
                        |> List.filter (hasPattern model.pattern)
                        |> preprocessCluster range.min range.max

                newModel =
                    { model
                        | min = range.min
                        , max = range.max
                        , numberOfClusters = List.length filteredClusters
                        , histogramData = List.map (\n -> List.length n.data) filteredClusters
                    }
            in
                ( newModel
                , Cmd.batch
                    [ draw ( filteredClusters, newModel.histogramData )
                    ]
                )

        FilterClusters pattern ->
            let
                filteredClusters =
                    model.displayedClusters
                        |> List.filter (hasPattern pattern)
                        |> preprocessCluster model.min model.max

                ( min, max ) =
                    getMinMaxClusterSize filteredClusters

                maxCorrected =
                    if max <= 0 then
                        1
                    else
                        max

                newModel =
                    { model
                        | title = model.title
                        , numberOfClusters = List.length filteredClusters
                        , histogramData = List.map (\n -> List.length n.data) filteredClusters
                        , pattern = pattern
                    }
            in
                ( newModel
                , Cmd.batch
                    [ sliderValue [ model.min, model.max ]
                    , draw ( filteredClusters, model.histogramData )
                    ]
                )



-- SUBSCRIPTIONS


port draw : ( Clusters, List Int ) -> Cmd msg


port sliderRange : List Int -> Cmd msg


port sliderValue : List Int -> Cmd msg


port dataClusters : (Model -> msg) -> Sub msg


port sliderChange : (Range -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ dataClusters DataClusters
        , sliderChange SliderChange
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ classList
            [ ( "row", True )
            ]
        ]
        [ parameters model.parameters
        , button [ onClick (DistanceCluster) ] [ text "Distance Clusters" ]
        , button [ onClick (TaxonomicCluster) ] [ text "Taxonomic Clusters" ]
        , input [ placeholder "Filter clusters", onInput FilterClusters ] []
        , div
            []
            [ h4 [] [ text (model.title ++ " (" ++ toString model.numberOfClusters ++ ")") ] ]
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


preprocessCluster : Int -> Int -> Clusters -> Clusters
preprocessCluster min max clusters =
    let
        betweenRange min max cluster =
            List.length cluster.data >= min && List.length cluster.data <= max
    in
        clusters
            |> List.filter (betweenRange min max)
            |> List.sortBy (\n -> List.length n.data)
            |> List.reverse


getMinMaxClusterSize : Clusters -> ( Int, Int )
getMinMaxClusterSize cluster =
    let
        minMax cluster range =
            let
                currentLength =
                    List.length cluster.data

                ( min, max ) =
                    range
            in
                ( Basics.min currentLength min, Basics.max currentLength max )
    in
        List.foldr minMax ( 0, 0 ) cluster


hasPattern : String -> Cluster -> Bool
hasPattern pattern cluster =
    let
        clusterContain d =
            case d.name of
                Nothing ->
                    False

                Just name ->
                    Regex.contains (Regex.caseInsensitive (Regex.regex pattern)) name
    in
        case cluster.name of
            Nothing ->
                False

            Just name ->
                Regex.contains (Regex.caseInsensitive (Regex.regex pattern )) name
                    || List.any clusterContain cluster.data
