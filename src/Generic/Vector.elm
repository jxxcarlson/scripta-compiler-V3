module Generic.Vector exposing (Vector, get, increment, init, set, toString)

{-| A fixed-size vector of integers for section/item numbering.
-}


type alias Vector =
    { size : Int, content : List Int }


init : Int -> Vector
init k =
    { size = k, content = List.repeat k 0 }


toString : Vector -> String
toString v =
    v.content
        |> List.filter (\x -> x > 0)
        |> List.map String.fromInt
        |> String.join "."


get : Int -> Vector -> Int
get k v =
    getAt k v.content |> Maybe.withDefault 0


set : Int -> Int -> Vector -> Vector
set k a v =
    { v | content = setAt k a v.content }


{-| Get element at index (0-based).
-}
getAt : Int -> List a -> Maybe a
getAt idx list =
    if idx < 0 then
        Nothing

    else
        List.head (List.drop idx list)


{-| Set element at index (0-based).
-}
setAt : Int -> a -> List a -> List a
setAt idx val list =
    List.indexedMap
        (\i x ->
            if i == idx then
                val

            else
                x
        )
        list


resetFrom : Int -> Vector -> Vector
resetFrom k v =
    let
        prefix =
            List.take k v.content

        suffix =
            List.repeat (v.size - k) 0
    in
    { size = v.size, content = prefix ++ suffix }


increment : Int -> Vector -> Vector
increment k v =
    if k < 0 || k >= v.size then
        v

    else
        set k (get k v + 1) v
            |> resetFrom (k + 1)


level : Vector -> Int
level v =
    List.filter (\i -> i /= 0) v.content |> List.length
