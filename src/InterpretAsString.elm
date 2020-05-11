module InterpretAsString exposing (check, evalExpr, evalExprList, evalResult)

import Parse exposing (Expr(..), parse)
import Parser exposing (DeadEnd)


{-| A round-trip test of the
validity of the parser.
-}
check : String -> Status
check str =
    case evalResult (parse str) == str of
        True ->
            Pass

        False ->
            Fail


type Status
    = Pass
    | Fail


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
