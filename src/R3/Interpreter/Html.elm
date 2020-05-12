module R2.Interpreter.Html exposing (..)

import Dict
import Maybe.Extra
import Parser exposing (DeadEnd)
import R2.Func as Func
import R2.Parse exposing (Expr(..), FuncName(..), parse)


{-| The functions `i` and `b` stand for italic and bold:

      > import R2.Parse exposing(..)
      > import R2.Interpreter.Html as H

      > parse "This is a [b [i real]] test" |> H.evalResult
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


evalExpr : Expr -> String
evalExpr expr =
    case expr of
        Word s ->
            s

        ExprList list ->
            List.map evalExpr list |> String.join " "

        FunctionApplication fns args ->
            let
                maybeFunc =
                    fns
                        |> List.map (\(F f_) -> Dict.get f_ Func.dict)
                        |> Maybe.Extra.values
                        |> Func.composeList
            in
            case maybeFunc of
                Nothing ->
                    " [f compose error: " ++ evalExpr args ++ "] "

                Just func ->
                    Func.apply func (evalExpr args)

        Function f ->
            String.trim f



-- HELPERS


tag : String -> String -> String
tag tag_ string =
    "<" ++ tag_ ++ ">" ++ string ++ "</" ++ tag_ ++ ">"


tagWithStyle : String -> String -> String -> String
tagWithStyle style tag_ string =
    "<" ++ tag_ ++ " style=" ++ style ++ " >" ++ string ++ "</" ++ tag_ ++ ">"


evalExprList : List Expr -> String
evalExprList list =
    tag "div" (List.map evalExpr list |> String.join "\n")
