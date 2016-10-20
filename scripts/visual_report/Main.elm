port module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex
import Json.Decode as Json
import MashTree



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
    { distanceClusters : Maybe ClustersByRank
    , taxonomicClusters : Maybe ClustersByRank
    , displayedClusters : Maybe ClustersByRank
    , parameters : List Parameters
    , title : String
    , min : Int
    , max : Int
    , numberOfClusters : Int
    , histogramData : List Int
    , pattern : String
    , rank : Rank
    , distance : Bool
    , taxonomy : Bool
    , showOrphan : Bool
    }


type alias ModelPort =
    { distanceClusters : ClustersByRank
    , taxonomicClusters : ClustersByRank
    , parameters :
        List Parameters
        --    , title             : String
        --    , min               : Int
        --    , max               : Int
        --    , numberOfClusters  : Int
        --    , histogramData     : List Int
        --    , pattern           : String
        --    , rank              :
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


type alias ClustersByRank =
    { strain : Clusters
    , species : Clusters
    , genus : Clusters
    , family : Clusters
    , order : Clusters
    , class : Clusters
    , phylum : Clusters
    }


type Rank
    = Strain
    | Species
    | Genus
    | Family
    | Order
    | Class
    | Phylum


type alias Clusters =
    List Cluster


type alias Cluster =
    { id : String, data : List ClusterObject, name : Maybe String }


type alias ClusterObject =
    { name : Maybe String, id : String, count : Int }


init : ( Model, Cmd Msg )
init =
    ( Model Nothing Nothing Nothing [] "" 0 1 0 [ 0 ] "" Genus True False False, Cmd.none )



-- UPDATE


type Msg
    = TaxonomicCluster
    | DistanceCluster
    | DataClusters ModelPort
    | SliderChange Range
    | FilterClusters String
    | ChangeRank String
    | ShowOrphan


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataClusters m ->
            let
                rank =
                    Genus
                        
                distanceClusters =
                    Just
                        (ClustersByRank
                            m.distanceClusters.strain
                            m.distanceClusters.species
                            m.distanceClusters.genus
                            m.distanceClusters.family
                            m.distanceClusters.order
                            m.distanceClusters.class
                            m.distanceClusters.phylum
                        )

                rankedDistanceClusters =
                    getClustersByRank rank distanceClusters

                taxonomicClusters =
                    Just
                        (ClustersByRank
                            m.taxonomicClusters.strain
                            m.taxonomicClusters.species
                            m.taxonomicClusters.genus
                            m.taxonomicClusters.family
                            m.taxonomicClusters.order
                            m.taxonomicClusters.class
                            m.taxonomicClusters.phylum
                        )

                ( min, max ) =
                    getMinMaxClusterSize rankedDistanceClusters

                filteredClusters =
                    case rankedDistanceClusters of
                        Nothing ->
                            []

                        Just clusters ->
                            clusters
                                |> List.filter (hasPattern "")
                                |> preprocessCluster min max model.showOrphan

                numOfClusters =
                    (List.length filteredClusters)

                histogramData =
                    (List.map (\n -> List.length n.data) filteredClusters)
            in
                ( Model
                      distanceClusters
                      taxonomicClusters
                      distanceClusters
                      m.parameters
                      "Distance Clusters"
                      min
                      max
                      numOfClusters
                      histogramData
                      ""
                      rank
                      True
                      False
                      False
                , Cmd.batch
                    [ sliderRange [ min, max ]
                    , sliderValue [ min, max ]
                    , draw ( filteredClusters, histogramData )
                    ]
                )

        -- TAXONOMIC
        TaxonomicCluster ->
            let
                clusters =
                    getClustersByRank model.rank model.taxonomicClusters

                filteredClusters =
                    case clusters of
                        Nothing ->
                            []

                        Just clu ->
                            clu
                                |> List.filter (hasPattern model.pattern)
                                |> preprocessCluster min max model.showOrphan

                ( min, max ) =
                    getMinMaxClusterSize clusters

                newModel =
                    { model
                        | title = "Taxonomic clusters"
                        , displayedClusters = model.taxonomicClusters
                        , numberOfClusters = List.length filteredClusters
                        , histogramData = List.map (\n -> List.length n.data) filteredClusters
                        , taxonomy = True
                        , distance = False

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
                clusters =
                    getClustersByRank model.rank model.distanceClusters

                filteredClusters =
                    case clusters of
                        Nothing ->
                            []

                        Just c ->
                            c
                                |> List.filter (hasPattern model.pattern)
                                |> preprocessCluster min max model.showOrphan

                ( min, max ) =
                    getMinMaxClusterSize clusters

                newModel =
                    { model
                        | title = "Distance Clusters"
                        , displayedClusters = model.distanceClusters
                        , numberOfClusters = List.length filteredClusters
                        , histogramData = List.map (\n -> List.length n.data) filteredClusters
                        , taxonomy = False
                        , distance = True

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
                displayedClusters =
                    getClustersByRank model.rank model.displayedClusters

                filteredClusters =
                    case displayedClusters of
                        Nothing ->
                            []

                        Just clust ->
                            clust
                                |> List.filter (hasPattern model.pattern)
                                |> preprocessCluster range.min range.max model.showOrphan

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
                displayedClusters =
                    getClustersByRank model.rank model.displayedClusters

                filteredClusters =
                    case displayedClusters of
                        Nothing ->
                            []

                        Just clust ->
                            clust
                                |> List.filter (hasPattern pattern)
                                |> preprocessCluster model.min model.max model.showOrphan

                ( min, max ) =
                    getMinMaxClusterSize (Just filteredClusters)

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

        ChangeRank val ->
            let
                rank =
                    getRank val

                    
                displayedClusters =
                    getClustersByRank rank model.displayedClusters

                ( min, max ) =
                    getMinMaxClusterSize displayedClusters

                filteredClusters =
                    case displayedClusters of
                        Nothing ->
                            []

                        Just clust ->
                            clust
                                |> List.filter (hasPattern model.pattern)
                                |> preprocessCluster min max model.showOrphan

                newModel =
                    { model
                        | numberOfClusters = List.length filteredClusters
                        , histogramData = List.map (\n -> List.length n.data) filteredClusters
                        , rank = rank
                    }
            in
                ( newModel
                , Cmd.batch
                    [ sliderRange [ min, max ]
                    , sliderValue [ min, max ]
                    , draw ( filteredClusters, newModel.histogramData )
                    ]
                )

        ShowOrphan ->
            let
                displayedClusters =
                    getClustersByRank model.rank model.displayedClusters
       
                showOrphan = not model.showOrphan

                           
                ( min, max ) =
                    getMinMaxClusterSize displayedClusters

                filteredClusters =
                    case displayedClusters of
                        Nothing ->
                            []

                        Just clust ->
                            clust
                                |> List.filter (hasPattern model.pattern)
                                |> preprocessCluster min max showOrphan

                numOfClusters =
                    (List.length filteredClusters)

                newModel =
                    { model
                        | showOrphan = showOrphan
                        , histogramData = List.map (\n -> List.length n.data) filteredClusters
                        , numberOfClusters = numOfClusters
                    }
                
            in
              ( newModel
                , Cmd.batch
                    [ sliderRange [ min, max ]
                    , sliderValue [ min, max ]
                    , draw ( filteredClusters, newModel.histogramData )
                    ]
                )   

-- SUBSCRIPTIONS


-- send through port

port draw : ( Clusters, List Int ) -> Cmd msg


port deletePies : String -> Cmd msg


port sliderRange : List Int -> Cmd msg


port sliderValue : List Int -> Cmd msg


-- Get from port
                   
port dataClusters : (ModelPort -> msg) -> Sub msg


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
    Html.form
        [ classList
            [ ( "ui", True )
            , ( "form", True )
            ]
        ]
        [ parameters model.parameters
        , div
              [class "inline fields"]
              [ div
                [ class "field" ]
                [ select
                      [ class "ui dropdown"
                      , on "change" (Json.map ChangeRank targetValue)
                      ]
                  (rankOptions model)
            ]
        , div
              [ class "field" ]
              [ input [ placeholder "Filter clusters", onInput FilterClusters ] []
              ]
        , div
              [ class "field" ]
              [ div
                [ class "ui checkbox"]
                [ input [type' "checkbox", onClick ShowOrphan ] [text "orphan"]
                , label [checked model.showOrphan] [text "Show Orphan" ]    
                ]
              ]

        , div
              [class "field"]
              [ div
                [ class "ui basic buttons"]
                [ div
                  [ classList
                        [ ("ui", True)
                        , ("button", True)
                        , ("active", model.distance)
                        ]
                  , onClick (DistanceCluster)
                  ] [ text "Distance Clusters" ]
                , div [ classList
                            [ ("ui", True)
                            , ("button", True)
                            , ("active", model.taxonomy)
                            ]
                      , onClick (TaxonomicCluster)
                      ] [ text "Taxonomic Clusters" ]
                ]
              , a [ class "ui grey circular label"]
                  [ text (toString model.numberOfClusters)]
              ]
        ]
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
            [ class "ui celled table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "Kmer size" ]
                    , th [] [ text "Number Sketches" ]
                    , th [] [ text "P-value Threshold" ]
                    , th [] [ text "Distance Threshold" ]
                    ]
                ]
            , tbody [] (List.map row params)
            ]


preprocessCluster : Int -> Int -> Bool -> Clusters -> Clusters
preprocessCluster min max showOrphan clusters =
    let
        betweenRange min max cluster =
                List.length cluster.data >= min && List.length cluster.data <= max
            
            
        isOrphan showOrphan cluster =
            let
                count = List.foldr (\n c-> n.count+c ) 0 cluster.data
            in
                if (not showOrphan && count == 1) then False else True
    in
                clusters
                    |> List.filter (isOrphan showOrphan)
                    |> List.filter (betweenRange min max)
                    |> List.sortBy (\n -> List.length n.data)
                    |> List.reverse


getMinMaxClusterSize : Maybe Clusters -> ( Int, Int )
getMinMaxClusterSize cluster =
    case cluster of
        Nothing ->
            ( 0, 0 )

        Just cluster ->
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
                Regex.contains (Regex.caseInsensitive (Regex.regex pattern)) name
                    || List.any clusterContain cluster.data


getClustersByRank : Rank -> Maybe ClustersByRank -> Maybe Clusters
getClustersByRank rank clustersByRank =
    case clustersByRank of
        Nothing ->
            Nothing

        Just clusters ->
            case rank of
                Strain ->
                    Just clusters.strain
                        
                Species ->
                    Just clusters.species

                Genus ->
                    Just clusters.genus

                Family ->
                    Just clusters.family

                Order ->
                    Just clusters.order

                Class ->
                    Just clusters.class

                Phylum ->
                    Just clusters.phylum


getRank : String -> Rank
getRank rankStr =
    case rankStr of
        "strain" ->
            Strain

        "species" ->
            Species

        "genus" ->
            Genus

        "family" ->
            Family

        "order" ->
            Order

        "class" ->
            Class

        "phylum" ->
            Phylum

        _ ->
            Genus


rankOptions : Model -> List (Html a)
rankOptions model =
    let
        ranks =
            [ Strain, Species, Genus, Family, Order, Class, Phylum ]
                
        rankModel = model.rank

        toOption rank =
            case rank of
                Strain ->
                    option [ value "strain", selected (rankModel == rank) ] [ text "Strain" ]

                Species ->
                    option [ value "species", selected (rankModel == rank) ] [ text "Species" ]

                Genus ->
                    option [ value "genus", selected (rankModel == rank)] [ text "Genus" ]

                Family ->
                    option [ value "family", selected (rankModel == rank) ] [ text "Family" ]

                Order ->
                    option [ value "order", selected (rankModel == rank) ] [ text "Order" ]

                Class ->
                    option [ value "class", selected (rankModel == rank) ] [ text "Class" ]

                Phylum ->
                    option [ value "phylum", selected (rankModel == rank) ] [ text "Phylum" ]
    in
        List.map toOption ranks
