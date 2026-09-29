module Parser.PipelineTest exposing (..)

import Dict
import Either exposing (Either(..))
import Expect
import Parser.Pipeline exposing (toExpressionBlock)
import Parser.PrimitiveBlock
import Test exposing (..)
import V3.Types exposing (Expr(..), ExprMeta, ExpressionBlock, Heading(..), PrimitiveBlock)


suite : Test
suite =
    describe "Parser.Pipeline"
        [ describe "toExpressionBlock"
            [ test "converts paragraph block with parsed expressions" <|
                \_ ->
                    let
                        primitive : PrimitiveBlock
                        primitive =
                            { heading = Paragraph
                            , indent = 0
                            , args = []
                            , properties = Dict.empty
                            , firstLine = "Hello [b world]!"
                            , body = [ "Hello [b world]!" ]
                            , meta =
                                { id = "1-0"
                                , position = 0
                                , lineNumber = 1
                                , numberOfLines = 1
                                , begin = 0
                                , end = String.length "Hello [b world]!"
                                , contentBegin = 0
                                , contentEnd = String.length "Hello [b world]!"
                                , messages = []
                                , sourceText = "Hello [b world]!"
                                , error = Nothing
                                , bodyLineNumber = 1
                                }
                            , style = {}
                            }

                        result =
                            toExpressionBlock primitive
                    in
                    case result.body of
                        Right exprs ->
                            Expect.equal 3 (List.length exprs)

                        Left _ ->
                            Expect.fail "Expected Right with expressions"
            , test "converts verbatim block preserving raw text" <|
                \_ ->
                    let
                        primitive : PrimitiveBlock
                        primitive =
                            { heading = Verbatim "math"
                            , indent = 0
                            , args = []
                            , properties = Dict.empty
                            , firstLine = ""
                            , body = [ "a^2 + b^2 = c^2" ]
                            , meta =
                                { id = "2-0"
                                , position = 0
                                , lineNumber = 2
                                , numberOfLines = 1
                                , begin = 0
                                , end = String.length "$$\na^2 + b^2 = c^2"
                                , contentBegin = 3
                                , contentEnd = String.length "$$\na^2 + b^2 = c^2"
                                , messages = []
                                , sourceText = "$$\na^2 + b^2 = c^2"
                                , error = Nothing
                                , bodyLineNumber = 3
                                }
                            , style = {}
                            }

                        result =
                            toExpressionBlock primitive
                    in
                    case result.body of
                        Left text ->
                            Expect.equal "a^2 + b^2 = c^2" text

                        Right _ ->
                            Expect.fail "Expected Left with raw text"
            , test "converts item block with ExprList" <|
                \_ ->
                    let
                        primitive : PrimitiveBlock
                        primitive =
                            { heading = Ordinary "item"
                            , indent = 0
                            , args = []
                            , properties = Dict.empty
                            , firstLine = "First item"
                            , body = []
                            , meta =
                                { id = "3-0"
                                , position = 0
                                , lineNumber = 3
                                , numberOfLines = 1
                                , begin = 0
                                , end = String.length "- First item"
                                , contentBegin = 0
                                , contentEnd = String.length "- First item"
                                , messages = []
                                , sourceText = "- First item"
                                , error = Nothing
                                , bodyLineNumber = 3
                                }
                            , style = {}
                            }

                        result =
                            toExpressionBlock primitive
                    in
                    case result.body of
                        Right [ ExprList _ _ _ ] ->
                            Expect.pass

                        Right _ ->
                            Expect.fail "Expected single ExprList"

                        Left _ ->
                            Expect.fail "Expected Right with ExprList"
            , test "inserts id into properties" <|
                \_ ->
                    let
                        primitive : PrimitiveBlock
                        primitive =
                            { heading = Paragraph
                            , indent = 0
                            , args = []
                            , properties = Dict.empty
                            , firstLine = "Test"
                            , body = [ "Test" ]
                            , meta =
                                { id = "my-id"
                                , position = 0
                                , lineNumber = 1
                                , numberOfLines = 1
                                , begin = 0
                                , end = String.length "Test"
                                , contentBegin = 0
                                , contentEnd = String.length "Test"
                                , messages = []
                                , sourceText = "Test"
                                , error = Nothing
                                , bodyLineNumber = 1
                                }
                            , style = {}
                            }

                        result =
                            toExpressionBlock primitive
                    in
                    Expect.equal (Just "my-id") (Dict.get "id" result.properties)
            ]
        , describe "table expression ids"
            [ test "cell expressions carry the source line number of their row" <|
                \_ ->
                    let
                        rowIds : Expr ExprMeta -> List String
                        rowIds expr =
                            case expr of
                                ExprList _ cells _ ->
                                    List.concatMap rowIds cells

                                Text _ meta ->
                                    [ meta.id ]

                                Fun _ args meta ->
                                    meta.id :: List.concatMap rowIds args

                                VFun _ _ meta ->
                                    [ meta.id ]

                        ids =
                            "intro\n\n| table\na & b\nc & d\n"
                                |> String.lines
                                |> Parser.PrimitiveBlock.parse
                                |> List.map toExpressionBlock
                                |> List.filter (\b -> b.heading == Ordinary "table")
                                |> List.concatMap
                                    (\b ->
                                        case b.body of
                                            Right rows ->
                                                List.map rowIds rows

                                            Left _ ->
                                                []
                                    )
                    in
                    Expect.equal [ [ "e-3.0", "e-3.0" ], [ "e-4.0", "e-4.0" ] ] ids
            ]
        ]
