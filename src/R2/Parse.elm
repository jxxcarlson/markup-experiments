module R2.Parse exposing (Expr(..), FuncName(..), functionApplication, functionExpression, parse)

import Parser exposing (..)


type Expr
    = Word String
    | ExprList (List Expr)
    | Function String
    | FunctionApplication (List FuncName) Expr


type FuncName
    = F String


{-|

> parse "[red.i.b test]" |> evalResult
> "<div><span style=font-weight:bold;font-style:italic;color:red;foo:bar >test</span></div>

-}
parse : String -> Result (List DeadEnd) (List Expr)
parse =
    run exprList



-- CONSTANTS


openTermC =
    '['


openTermS =
    String.fromChar openTermC


closeTermC =
    ']'


closeTermS =
    String.fromChar closeTermC



-- EXPR


expr : Parser Expr
expr =
    oneOf [ functionApplication, words ]


exprList : Parser (List Expr)
exprList =
    manyp expr


manyp : Parser a -> Parser (List a)
manyp parser =
    loop ( 0, [] ) <|
        ifProgress <|
            parser


ifProgress : Parser a -> ( Int, List a ) -> Parser (Step ( Int, List a ) (List a))
ifProgress parser ( offset, vs ) =
    succeed (\v n -> ( n, v ))
        |= parser
        |= getOffset
        |> map
            (\( newOffset, v ) ->
                if offset == newOffset then
                    Done (List.reverse vs)

                else
                    Loop ( newOffset, v :: vs )
            )



-- FUNCTION EXPRESSIONS, ETC.


{-|

    > run functionExpression "foo.bar.baz"
    Ok ["foo","bar","baz"]

-}
functionExpression =
    (succeed (\head tail -> head :: tail)
        |. symbol openTermS
        |= word_
        |= functionExpressionElements
        |. spaces
    )
        |> map (List.filter (\x -> x /= ""))
        |> map (List.map String.trim)
        |> map (List.map F)


functionExpressionElements =
    manyp (oneOf [ functionExpressionElement, succeed () |> map (\_ -> "") ])


functionExpressionElement =
    succeed identity
        |. symbol "."
        |= word_


functionApplication : Parser Expr
functionApplication =
    succeed FunctionApplication
        |= functionExpression
        |= lazy (\_ -> exprList |> map ExprList)
        |. symbol closeTermS
        |. oneOf [ symbol " ", succeed () ]


function : Parser Expr
function =
    succeed Function
        |. symbol openTermS
        |= word_
        |. symbol " "



-- WORD


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


word : Parser Expr
word =
    word_ |> map Word


word_ : Parser String
word_ =
    getChompedString <|
        succeed ()
            |. chompIf (\c -> c /= ' ' && c /= openTermC && c /= closeTermC && c /= '.')
            |. chompWhile (\c -> c /= ' ' && c /= closeTermC && c /= '.')
            |. chompWhile (\c -> c == ' ')



-- HELPERS


oneSpace : Parser ()
oneSpace =
    succeed ()
        |. chompIf (\c -> c == ' ')


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
