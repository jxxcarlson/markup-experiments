module R3.Interpreter.Html exposing (..)

import Dict
import Maybe.Extra
import Parser exposing (DeadEnd)
import R3.Func as Func
import R3.Parse exposing (Expr(..), FuncName(..), parse)


{-| The functions `i` and `b` stand for italic and bold:

      > import R3.Parse exposing(..)
      > import R3.Interpreter.Html as H

      > parse "This is a [b.i real] test" |> H.evalResult
      "<div>This  is  a
      <span style=font-weight:bold ><span style=font-style:italic >real</span></span>
      test</div>"

      > parse "This is geek stuff: [code x = x + 1]" |> H.evalResult
      "<div>This  is  geek  stuff: \n<code>x  =  x  +  1</code></div>"

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
