port module MashTree exposing (..)

--import Html.Events exposing (..)
import Html exposing (..)
import Html.App as App
import Html.Attributes as Att exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Json.Encode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import String
import Task
import Taxonomy as Taxo exposing (..)
import Taxonomy.Rank as Rank exposing (..)

main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--Model
type alias Model =
    { clusterId       : String
    , clusterDistance : (List (List (Maybe Float)))
    , clusterTaxa     : Maybe (List Taxa)
    , tree            : Maybe Tree
    , rank            : Rank.Rank
    , url             : String
    , error           : Maybe String
    }



type alias Tree =
    { children : Maybe Nodes
    , length   : Maybe Float
    , taxon    : Maybe Taxa
    , height   : Maybe TreeHeight
    }


type Nodes = Nodes (List Tree)
    

type alias TreeHeight =
    { left : Int
    , right : Int
    }
    
type alias Taxa =
    { id : Int
    , name : String
    , taxonomy : Taxo.Taxonomy
    }

defaultModel : Model
defaultModel = Model "" ([[Nothing]]) Nothing Nothing (Species Nothing) "" Nothing
    
init : ( Model, Cmd Msg )
init = (defaultModel, Cmd.none)
       


type Msg
    = ClusterId String
    | ReceiveUrl (String, String)
    | FetchSucceed (List (List String))
    | FetchTaxaSucceed (List Taxa)
    | FetchFail Http.Error
    | FetchTreeSucceed Tree
    | ChangeRank String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClusterId id ->
            let
                cleanId = (String.dropLeft 1 id)
                _ = Debug.log "Get id" id
                
            in
            ( {model | clusterId = cleanId }
            , Cmd.batch
                [ getTree model.url cleanId
                --, getTaxa model.url cleanId
                --, getDistance model.url cleanId
                ]
            )
                
        ReceiveUrl urlTuple ->
            let
                (url, id) = urlTuple
                            
                cleanId = (String.dropLeft 1 id)
                          
                _ = Debug.log "init url = " url
                _ = Debug.log "init url = " cleanId
            in
                ( {model | url = url, clusterId = cleanId }
                , Cmd.batch
                      [ getTree url cleanId
                      --, getDistance url cleanId
                      ]
                )
            
            
        FetchSucceed distance ->
            let
                distanceInt =
                    List.map
                        (\tab -> List.map (\d -> Result.toMaybe (String.toFloat d) ) tab )
                        distance
                    
            in
                ( {model | clusterDistance = distanceInt }
                , Cmd.none
                )

        FetchFail error ->
            case error of
                
                Http.UnexpectedPayload errorMessage ->
                    Debug.log errorMessage
                        (model, Cmd.none)

                _ ->
                    (model, Cmd.none)


        FetchTaxaSucceed taxonomy ->
            let
                taxo = List.map (\n -> encodeTaxa n ) taxonomy
                       
            in
                ( model
                , calculateTree (model.clusterDistance, taxo)
                )
                
        FetchTreeSucceed tree ->
            let
                -- _ = Debug.log "tree : " tree
                jsonTree = encodeTree tree
                rankStr = (Rank.typeOfRank model.rank)
                          
                listCommand = [drawTree (jsonTree, rankStr)]

            in
                ( { model | tree = Just tree}
                , Cmd.batch listCommand
                )



        ChangeRank rank ->
            let
                resRankType = Rank.resultRankOfMaybeRankInfo rank Nothing
                commandOnRank rank =
                    case model.tree of
                        Nothing ->
                            ({model | error = Just "No tree available", rank = rank}, [Cmd.none])
                                
                        Just tree ->
                            let 
                                jsonTree = encodeTree tree
                                rankStr = Rank.typeOfRank rank
                            in
                                ({model | error = Nothing, rank = rank},[drawTree (jsonTree, rankStr)])
                    
                (newModel, listCommand) =
                    case resRankType of
                        Ok rank ->
                            commandOnRank rank
                                
                        Err error ->
                            ({model | error = Just error, rank = (Species Nothing)}, [Cmd.none])

            in
               ( newModel, Cmd.batch listCommand) 
            

port clusterId : (String -> msg) -> Sub msg
                 
port url : ( (String, String) -> msg ) -> Sub msg

port calculateTree : ( List (List (Maybe Float)), List Value) -> Cmd msg

port drawTree : (Value, String) -> Cmd msg


                 
                
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ url ReceiveUrl
        --, clusterId ClusterId
        ]
       
view : Model -> Html Msg
view model =
    --button [onClick Display ] [ text "getTree"]
    div
    [ class "sixteen wide column"]
    [ div
      [class "row"]
      [a
        [ href (model.url ++ "/index.html") ]
        [ text "Go back to the clusters"]
      ]
    , div
          [class "row"]
          [ text model.clusterId
          , select
                [ class "ui dropdown"
                , on "change" (Json.map ChangeRank targetValue)
                ]
                (rankOptions model)
          ]
    , (displayErrorMsg model)
    -- , div
    --       [class "row"]
    --       [ div
    --         [ class "sixteen wide column" ]
    --         [distanceMatrixTable model.clusterDistance]
    --       ]
    ]

displayErrorMsg : Model -> Html b
displayErrorMsg model =
    case model.error of
        Nothing ->
            div [] []
        Just error ->
            div
            [class "row"]
            [ div
              [ class "sixteen wide column" ]
              [ div
                [ class "ui warning message"]
                [ i [class "close icon"] []
                , text error
                ]
              ]
            ]
            

-- depthFirstTraversal tree =
--     case tree.children of
--         Nothing ->
--             let 
--                 _ = Debug.log "leaf" "leaf"
--             in
--                 1
                    
--         Just children ->
--             case children of
--                 [] ->
--                     1
                        
--                 [t] ->
--                     (depthFirstTraversal t)

--                 hd :: tl ->
--                     let
--                         foldf tree acc =
--                             depthFirstTraversal tree + acc
                                
--                         left = depthFirstTraversal hd
                               
--                         right = List.foldl foldf 0 tl 
--                     in
--                         left + right
            
getDistance : String -> String -> Cmd Msg
getDistance baseUrl id =
    let
        url = baseUrl ++ "/results/distance-matrices/" ++ id ++ "-distance-matrix.json"
    in
        Task.perform FetchFail FetchSucceed (Http.get decodeDistanceUrl url)


getTaxa : String -> String -> Cmd Msg
getTaxa baseUrl id =
    let
        url = baseUrl ++ "/results/distance-matrices/" ++ id ++ "-taxa.json"
        _ = Debug.log "url" url
    in
        Task.perform FetchFail FetchTaxaSucceed (Http.get decodeTaxaUrl url)

getTree : String -> String -> Cmd Msg
getTree baseUrl id =
    let
        url = baseUrl ++ "/results/trees/" ++ id ++ "-tree.json"
        _ = Debug.log "url" url
    in
        Task.perform FetchFail FetchTreeSucceed (Http.get decodeTree url)



toValidTaxid : String -> Result String Int
toValidTaxid taxid =
        if taxid == ""
        then  Ok 0
        else  String.toInt taxid
            
            
number : Json.Decoder Int
number =
    Json.oneOf
        [ Json.int
        , Json.customDecoder Json.string String.toInt
        , Json.customDecoder Json.string toValidTaxid
        ]
        

        
decodeDistanceUrl : Json.Decoder (List (List String))
decodeDistanceUrl =
    Json.list (Json.list Json.string)

        
lazy : (() -> Json.Decoder a) -> Json.Decoder a
lazy thunk =
    Json.customDecoder Json.value
        (\js -> Json.decodeValue (thunk ()) js)

            
decodeTree : Json.Decoder Tree
decodeTree =
    decode Tree
        |> Json.Decode.Pipeline.required "children" (Json.Decode.Pipeline.nullable decodeNodes)
        |> Json.Decode.Pipeline.required "length" (Json.Decode.Pipeline.nullable Json.float)
        |> Json.Decode.Pipeline.required "taxon" (Json.Decode.Pipeline.nullable decodeTaxa)
        |> Json.Decode.Pipeline.optional "height" (Json.maybe decodeHeight) Nothing
    

decodeNodes : Json.Decoder Nodes
decodeNodes =
    Json.map Nodes (Json.list (lazy (\_ -> decodeTree)))
        
decodeHeight : Json.Decoder TreeHeight
decodeHeight =
    decode TreeHeight
        |> Json.Decode.Pipeline.required "left" Json.int
        |> Json.Decode.Pipeline.required "right" Json.int
           
decodeChildren : Json.Decoder Nodes
decodeChildren =
    decode Nodes
        |> Json.Decode.Pipeline.custom (Json.list decodeTree)

           
decodeTaxaUrl : Json.Decoder (List Taxa)
decodeTaxaUrl =
    Json.list decodeTaxa

        
decodeTaxa : Json.Decoder Taxa
decodeTaxa =
    decode Taxa
        |> Json.Decode.Pipeline.required "id" number
        |> Json.Decode.Pipeline.required "name"     Json.string
        |> Json.Decode.Pipeline.required "taxonomy" Taxo.decodeTaxonomy

           
-- decodeRank : Json.Decoder Rank
-- decodeRank =
--     decode Rank
--         |> Json.Decode.Pipeline.required "taxid" (Json.Decode.Pipeline.nullable number)
--         |> Json.Decode.Pipeline.required "name" (Json.Decode.Pipeline.nullable Json.string)


encodeTree : Tree -> Value
encodeTree record =
    let
        length =
            case record.length of
                Nothing -> Json.Encode.null
                Just v -> Json.Encode.float v

        taxon =
            case record.taxon of
                Nothing -> Json.Encode.null 
                Just v  -> encodeTaxa v

        children =
            case record.children of
                Nothing -> Json.Encode.null
                Just v  ->
                    case v of
                        Nodes trees ->
                            if List.length trees == 0
                            then Json.Encode.null
                            else encodeNodes v 
    in
        Json.Encode.object
            [ ("children", children)
            , ("length", length)
            , ("taxon", taxon)
            ]

encodeNodes : Nodes -> Value
encodeNodes nodes =
    case nodes of
        Nodes trees ->
            let
                children =  List.map encodeTree trees
                -- _ = Debug.log "children" (Json.Encode.list children)
            in
                Json.Encode.list children
    

encodeTaxa : Taxa -> Value
encodeTaxa record =
    Json.Encode.object
        [ ("id", Json.Encode.int record.id)
        , ("name", Json.Encode.string record.name)
        , ("taxonomy", Taxo.encodeTaxonomy record.taxonomy)
        ]

  

distanceMatrixTable : List (List (Maybe a)) -> Html b
distanceMatrixTable matrix =
    let
        distanceCol distance =
            let
                dist =
                    case distance of
                        Just val ->
                            toString val
                                
                        Nothing ->
                            "NaN"
            in
            td [] [ text dist ]
                
        distanceRow distances =
            tr [] (List.map distanceCol distances)
            
    in
        table [class "ui celled table"] (List.map distanceRow matrix)



rankOptions : Model -> List (Html a)
rankOptions model =
    let
        ranks = Rank.getAllRankString
                
        rankStr =
            Rank.typeOfRank model.rank

        toOption rank =
            case rank of
                "oid" ->
                    option [ value "oid", selected (rankStr == rank) ] [ text "Oid" ]

                "strain" ->
                    option [ value "strain", selected (rankStr == rank) ] [ text "Strain" ]

                
                "species" ->
                    option [ value "species", selected (rankStr == rank) ] [ text "Species" ]

                "genus" ->
                    option [ value "genus", selected (rankStr == rank)] [ text "Genus" ]

                "family" ->
                    option [ value "family", selected (rankStr == rank) ] [ text "Family" ]

                "order" ->
                    option [ value "order", selected (rankStr == rank) ] [ text "Order" ]

                "class" ->
                    option [ value "class_", selected (rankStr == rank) ] [ text "Class" ]

                "phylum" ->
                    option [ value "phylum", selected (rankStr == rank) ] [ text "Phylum" ]

                _ ->
                    option [ value ""] [ text "" ]
    in
        List.map toOption ranks


