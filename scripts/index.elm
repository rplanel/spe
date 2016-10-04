port module Main exposing (..)
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode as Json exposing ((:=))
import Task


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
    { distanceClusters : Clusters, taxonomicClusters : Clusters, displayedClusters : Clusters}

        
type alias Clusters =
    List Cluster


type alias Cluster =
    { id : String, data : List ClusterObject, name : Maybe String }


type alias ClusterObject =
    { name : Maybe String, id : String, count : Int }


init : ( Model, Cmd Msg )
init =
    ( Model [] [] [], Cmd.none)



-- JSON DECODERS
-- Decode an element of a cluster


-- decodeclusterObject : Json.Decoder ClusterObject
-- decodeclusterObject =
--     Json.object3 ClusterObject ("name" := Json.maybe Json.string) ("id" := Json.string) ("count" := Json.int)



-- Decode a cluster object


-- decodeClusterObjects : Json.Decoder (List ClusterObject)
-- decodeClusterObjects =
--     Json.list decodeclusterObject



-- Decode a cluster from JSON


-- decodeCluster : Json.Decoder Cluster
-- decodeCluster =
--     Json.object3 Cluster ("id" := Json.string) ("data" := decodeClusterObjects) ("name" := Json.maybe Json.string)


-- decodeClusters : Json.Decoder (List Cluster)
-- decodeClusters =
--     Json.list decodeCluster



-- UPDATE


type Msg
    = TaxonomicCluster Clusters
    | DistanceCluster Clusters
    | DataClusters Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataClusters m ->
            (Model m.distanceClusters m.taxonomicClusters m.distanceClusters, Cmd.none)
            
        TaxonomicCluster clusters ->
            let
                newModel = Model model.distanceClusters clusters clusters
            in
                ( newModel , Cmd.none )

        DistanceCluster clusters ->
            let
                newModel = Model clusters model.taxonomicClusters clusters
            in
                ( newModel, Cmd.none )




-- SUBSCRIPTIONS

port dataClusters  : (Model -> msg) -> Sub msg
                         
subscriptions : Model -> Sub Msg
subscriptions model =
    dataClusters DataClusters



-- HTTP


-- getDistanceClusters : String -> Cmd Msg
-- getDistanceClusters url =
--     Task.perform FetchFail FetchSucceed (Http.get decodeClusters url)



-- VIEW


view model =
    div
    [ classList
            [ ( "row", True )
            ]
        ]
        [
         button [onClick (DistanceCluster model.distanceClusters)] [text "Distance Clusters" ]
        ,button [onClick (TaxonomicCluster model.taxonomicClusters)] [text "Taxonomic Clusters" ]
        ,text (toString (List.length model.displayedClusters))
        ]
