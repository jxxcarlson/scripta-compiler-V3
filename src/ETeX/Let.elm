module ETeX.Let exposing (reduce)


type alias Definition =
    { variable : Char
    , expr : String
    }


type alias LetBlock =
    { definitions : List Definition
    , body : String
    }


reduce : String -> String
reduce input =
    input
