module Generic.VectorTest exposing (..)

import Expect
import Generic.Vector as Vector exposing (Vector)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Generic.Vector"
        [ describe "init"
            [ test "init 4 produces size=4, content=[0,0,0,0]" <|
                \_ ->
                    Vector.init 4
                        |> Expect.equal { size = 4, content = [ 0, 0, 0, 0 ] }
            ]
        , describe "increment"
            [ test "increment 0 on init 4 gives [1,0,0,0]" <|
                \_ ->
                    Vector.init 4
                        |> Vector.increment 0
                        |> .content
                        |> Expect.equal [ 1, 0, 0, 0 ]
            , test "increment 2 on [1,2,3,4] gives [1,2,4,0] (resets after)" <|
                \_ ->
                    { size = 4, content = [ 1, 2, 3, 4 ] }
                        |> Vector.increment 2
                        |> .content
                        |> Expect.equal [ 1, 2, 4, 0 ]
            , test "increment -1 returns vector unchanged" <|
                -- BUG M5: negative index guard
                \_ ->
                    let
                        v =
                            { size = 4, content = [ 1, 2, 3, 0 ] }
                    in
                    Vector.increment -1 v
                        |> Expect.equal v
            , test "increment 4 on size-4 vector returns unchanged" <|
                \_ ->
                    let
                        v =
                            { size = 4, content = [ 1, 2, 3, 0 ] }
                    in
                    Vector.increment 4 v
                        |> Expect.equal v
            ]
        , describe "get"
            [ test "get 0 on [5,6,7,8]" <|
                \_ ->
                    Vector.get 0 { size = 4, content = [ 5, 6, 7, 8 ] }
                        |> Expect.equal 5
            , test "get 3 on [5,6,7,8]" <|
                \_ ->
                    Vector.get 3 { size = 4, content = [ 5, 6, 7, 8 ] }
                        |> Expect.equal 8
            , test "get -1 returns 0" <|
                \_ ->
                    Vector.get -1 { size = 4, content = [ 5, 6, 7, 8 ] }
                        |> Expect.equal 0
            ]
        , describe "toString"
            [ test "toString on [1,2,0,0] gives \"1.2\"" <|
                \_ ->
                    Vector.toString { size = 4, content = [ 1, 2, 0, 0 ] }
                        |> Expect.equal "1.2"
            , test "toString on [0,0,0,0] gives \"\"" <|
                \_ ->
                    Vector.toString { size = 4, content = [ 0, 0, 0, 0 ] }
                        |> Expect.equal ""
            ]
        , describe "toStringWithLevel"
            [ test "toStringWithLevel 2 on [1,2,3,4] gives \"1.2\"" <|
                \_ ->
                    Vector.toStringWithLevel 2 { size = 4, content = [ 1, 2, 3, 4 ] }
                        |> Expect.equal "1.2"
            ]
        ]
