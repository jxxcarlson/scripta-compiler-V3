port module WorkerMain exposing (main)

{-| Benchmark worker for the `main` branch.
Only supports fullParse (no incremental parsing or ExpressionCache).
-}

import Json.Decode as Decode
import Parser.Forest
import TestData


port receiveCommand : ({ command : String, sourceText : String } -> msg) -> Sub msg


port sendResult : String -> Cmd msg


type alias Model =
    ()


type Msg
    = GotCommand { command : String, sourceText : String }


main : Program () Model Msg
main =
    Platform.worker
        { init = \_ -> ( (), Cmd.none )
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

                        ( _, forest ) =
                            Parser.Forest.parseToForestWithAccumulator params (String.lines sourceText)

                        -- Force evaluation by checking forest length
                        n =
                            List.length forest
                    in
                    ( model, sendResult (String.fromInt n) )

                _ ->
                    ( model, sendResult ("unknown command: " ++ command) )
