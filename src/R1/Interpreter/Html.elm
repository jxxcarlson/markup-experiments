module R1.Interpreter.Html exposing (..)

import Parser exposing (DeadEnd)
import R1.Parse exposing (Expr(..), parse)


{-| The functions `i` and `b` stand for itqlic and bold:

    > import R1.Parse exposing(parse)
    > import R1.Interpreter.Html exposing(evalResult)

    > parse "This is a [b [i real]] test" |> evalResult
      "<div>This  is  a
      <span style=font-weight:bold ><span style=font-style:italic >real</span></span>
      test</div>"

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
    "<" ++ tag_ ++ " style=" ++ style ++ " >" ++ string ++ "</" ++ tag_ ++ ">"


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
            let
                fName =
                    evalExpr f
            in
            case String.trim fName of
                "i" ->
                    tagWithStyle "font-style:italic" "span" (evalExpr args)

                "b" ->
                    tagWithStyle "font-weight:bold" "span" (evalExpr args)

                _ ->
                    tagWithStyle "font-color:red" "span" <|
                        "(Unknown "
                            ++ fName
                            ++ ": "
                            ++ evalExpr args

        Function s ->
            s
