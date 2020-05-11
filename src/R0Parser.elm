module R0Parser exposing (..)

import Parser exposing (..)


type Expr
    = Word String
    | ExprList (List Expr)
    | Function String
    | FunctionApplication Expr Expr



-- EXPR


expr : Parser Expr
expr =
    oneOf [ functionApplication, words2 ]


exprList : Parser Expr
exprList =
    many3 expr |> map ExprList


functionApplication : Parser Expr
functionApplication =
    succeed FunctionApplication
        |. symbol "<"
        |= (word_ |> map Function)
        |. oneSpace
        |= words2
        |. symbol ">"


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


words2 : Parser Expr
words2 =
    many2 word |> map ExprList



-- HELPERS


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
        , succeed ()
            |> map (\_ -> Done (List.reverse vs))
        ]


many2 : Parser a -> Parser (List a)
many2 p =
    loop [] (step2 p)


step2 : Parser a -> List a -> Parser (Step (List a) (List a))
step2 p vs =
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


many3 : Parser a -> Parser (List a)
many3 p =
    loop [] (step3 p)


step3 : Parser a -> List a -> Parser (Step (List a) (List a))
step3 p vs =
    oneOf
        [ succeed (\v -> Loop (v :: vs))
            |= p
        , succeed ()
            |> map (\_ -> Done (List.reverse vs))
        ]



{-

   > run (words |> andThen (\_ -> functionApplication)) "x y <f a b c>"
   Ok (FunctionApplication (Function "f") (ExprList [Word "a",Word "b",Word "c"]))

   > run (expr |> andThen (\_ -> expr)) "x y <f a b c>"
   Ok (FunctionApplication (Function "f") (ExprList [Word "a",Word "b",Word "c"]))

-}
