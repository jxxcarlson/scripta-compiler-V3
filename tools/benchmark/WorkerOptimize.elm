port module WorkerOptimize exposing (main)

{-| Benchmark worker for the `optimize` branch.
Supports fullParse, seedCache, incrementalParse, and cachedForest commands.
-}

import Dict
import Json.Decode as Decode
import Parser.Forest
import RoseTree.Tree as Tree exposing (Tree)
import TestData
import V3.Types exposing (Accumulator, ExpressionBlock, ExpressionCache)


port receiveCommand : ({ command : String, sourceText : String } -> msg) -> Sub msg


port sendResult : String -> Cmd msg


type alias Model =
    { cache : ExpressionCache
    , forest : List (Tree ExpressionBlock)
    , accumulator : Maybe Accumulator
    }


type Msg
    = GotCommand { command : String, sourceText : String }


main : Program () Model Msg
main =
    Platform.worker
        { init = \_ -> ( { cache = Dict.empty, forest = [], accumulator = Nothing }, Cmd.none )
        , update = update
        , subscriptions = \_ -> receiveCommand GotCommand
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotCommand { command, sourceText } ->
            case command of
                "fullParse" ->
                    let
                        params =
                            TestData.defaultCompilerParameters

                        ( acc, forest ) =
                            Parser.Forest.parseToForestWithAccumulator params (String.lines sourceText)

                        n =
                            List.length forest
                    in
                    ( { model | forest = forest, accumulator = Just acc }
                    , sendResult (String.fromInt n)
                    )

                "seedCache" ->
                    let
                        params =
                            TestData.defaultCompilerParameters

                        ( newCache, acc, forest ) =
                            Parser.Forest.parseIncrementally params model.cache (String.lines sourceText)

                        n =
                            List.length forest
                    in
                    ( { model | cache = newCache, forest = forest, accumulator = Just acc }
                    , sendResult (String.fromInt n)
                    )

                "incrementalParse" ->
                    let
                        params =
                            TestData.defaultCompilerParameters

                        ( newCache, acc, forest ) =
                            Parser.Forest.parseIncrementally params model.cache (String.lines sourceText)

                        n =
                            List.length forest
                    in
                    ( { model | cache = newCache, forest = forest, accumulator = Just acc }
                    , sendResult (String.fromInt n)
                    )

                "cachedForest" ->
                    -- Return stored forest without re-parsing.
                    -- Measures the "skip parse on non-edit interaction" optimization.
                    let
                        n =
                            List.length model.forest
                    in
                    ( model, sendResult (String.fromInt n) )

                _ ->
                    ( model, sendResult ("unknown command: " ++ command) )
