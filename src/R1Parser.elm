module R1Parser exposing (..)

import Parser exposing (..)


type Expr
    = Word String
    | ExprList (List Expr)
    | Function String
    | FunctionApplication Expr Expr



-- EXPR


expr : Parser Expr
expr =
    oneOf [ functionApplication, words, lazy (\_ -> expr) ]



-- FUNCTION
--functionApplication : Parser Expr
--functionApplication =
--    succeed FunctionApplication
--        |= function
--        --|= many (lazy (\_ -> expr))
--        |= many word
--        -- |. oneOf [ succeed (), oneSpace ]
--        --|= (word |> map (\x -> [ x ]))
--        |. symbol ">"


functionApplication2 =
    (getChompedString <|
        succeed ()
            |. symbol "<"
            |. chompWhile (\c -> c /= '>')
            |. symbol ">"
    )
        |> map (String.dropLeft 1)
        |> map (String.dropRight 1)


functionApplication =
    succeed FunctionApplication
        |. symbol "<"
        |= (word_ |> map Function)
        |. oneSpace
        |= words
        |. symbol ">"


foo =
    symbol "<" |> andThen (\_ -> word_)


bar =
    symbol "<" |> andThen (\_ -> word_) |> andThen (\_ -> symbol ">")


function : Parser Expr
function =
    succeed Function
        |. symbol "<"
        |= word_
        |. symbol " "



-- WORD


word : Parser Expr
word =
    word_ |> map Word


word_ : Parser String
word_ =
    getChompedString <|
        succeed ()
            |. chompIf (\c -> c /= ' ' && c /= '<' && c /= '>')
            |. chompWhile (\c -> c /= ' ' && c /= '>')


{-|

    > run words "a b c "
    Ok (ExprList [Word "a",Word "b",Word "c"])
        : Result (List Parser.DeadEnd) Expr
    > run words "a b c"
    Ok (ExprList [Word "a",Word "b",Word "c"])

-}
words : Parser Expr
words =
    many word |> map ExprList



-- MANY


spaces : Parser ()
spaces =
    succeed ()
        |. chompIf (\c -> c == ' ')
        |. chompWhile (\c -> c /= ' ')


oneSpace : Parser ()
oneSpace =
    succeed ()
        |. chompIf (\c -> c == ' ')


between : Parser opening -> Parser closing -> Parser a -> Parser a
between opening closing p =
    succeed identity
        |. opening
        |. spaces
        |= p
        |. spaces
        |. closing


pbrackets : Parser a -> Parser a
pbrackets =
    between (symbol "<") (symbol ">")


many : Parser a -> Parser (List a)
many p =
    loop [] (step p)


step : Parser a -> List a -> Parser (Step (List a) (List a))
step p vs =
    oneOf
        [ backtrackable <|
            succeed (\v -> Loop (v :: vs))
                |= p
                |. oneSpace
        , succeed (\v -> Loop (v :: vs))
            |= p
        , succeed ()
            |> map (\_ -> Done (List.reverse vs))
        ]
