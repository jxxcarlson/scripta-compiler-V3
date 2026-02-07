module Parser.PipelineTest exposing (..)

import Dict
import Either exposing (Either(..))
import Expect
import Parser.Pipeline exposing (toExpressionBlock)
import Test exposing (..)
import V3.Types exposing (Expr(..), ExpressionBlock, Heading(..), PrimitiveBlock)


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
        ]
