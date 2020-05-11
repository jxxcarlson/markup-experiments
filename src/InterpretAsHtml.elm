module InterpretAsHtml exposing (..)

import Parse exposing (Expr(..), parse)
import Parser exposing (DeadEnd)


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


tag : String -> String -> String
tag tag_ string =
    "<" ++ tag_ ++ ">" ++ string ++ "</" ++ tag_ ++ ">"


tagWithStyle : String -> String -> String -> String
tagWithStyle style tag_ string =
    "<" ++ tag_ ++ " style=" ++ style ++ "b>" ++ string ++ "</" ++ tag_ ++ ">"


evalExprList : List Expr -> String
evalExprList list =
    tag "div" (List.map evalExpr list |> String.join "\n")


evalExpr : Expr -> String
evalExpr expr =
    case expr of
        Word s ->
            s

        ExprList list ->
            List.map evalExpr list |> String.join " "

        FunctionApplication f args ->
            case f of
                "i" ->
                    tagWithStyle "font-style=italic" "span" (evalExpr args)

                "b" ->
                    tagWithStyle "font-style=bold" "span" (evalExpr args)

        Function s ->
            s
