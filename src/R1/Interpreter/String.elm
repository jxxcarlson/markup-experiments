module R1.Interpreter.String exposing (check, evalExpr, evalExprList, evalResult)

import Parser exposing (DeadEnd)
import R1.Parse exposing (Expr(..), parse)


{-| A round-trip test of the
validity of the parser.

    > import R1.Interpreter.String exposing(..)

    > check "Try [i [b this]]"
    (True,True)

    > check "Try [i [b this]] and that"
    (False,True)

The second example shows that the evalResult
is not a left inverse of parse, but may be
a left inverse modulo whitespace.

-}
check : String -> ( Bool, Bool )
check str =
    let
        roundTrip =
            evalResult (parse str)
    in
    ( roundTrip == str, String.replace " " "" roundTrip == String.replace " " "" str )


{-|

    > parse "a b [f [g y]]" |> evalResult
    "a b [f [g y]]"

-}
evalResult : Result (List DeadEnd) (List Expr) -> String
evalResult result =
    case result of
        Ok expr ->
            evalExprList expr

        Err _ ->
            "Parse error"


evalExprList : List Expr -> String
evalExprList list =
    List.map evalExpr list |> String.join ""


evalExpr : Expr -> String
evalExpr expr =
    case expr of
        Word s ->
            s

        ExprList list ->
            List.map evalExpr list |> String.join ""

        FunctionApplication f args ->
            "[" ++ evalExpr f ++ evalExpr args ++ "]"

        Function s ->
            s
