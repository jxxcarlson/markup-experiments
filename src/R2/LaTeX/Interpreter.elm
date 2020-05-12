module R2.LaTeX.Interpreter exposing (..)

import Dict
import Maybe.Extra
import Parser exposing (DeadEnd)
import R2.LaTeX.Func as Func
import R2.Parse exposing (Expr(..), FuncName(..), parse)


{-| The functions `i` and `b` stand for italic and bold:

      > import R2.Parse exposing(parse)
      > import R2.LaTeX.Interpreter exposing(evalResult)

      > parse "This is a [b.i real] test" |> evalResult
      "This  is  a \\textbf{\\textit{real}} test"

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
                func =
                    fns
                        |> List.map (\(F f_) -> Dict.get f_ Func.dict)
                        |> Maybe.Extra.values
                        |> Func.composeList
            in
            Func.apply func (evalExpr args)

        Function f ->
            String.trim f



-- HELPERS


evalExprList : List Expr -> String
evalExprList list =
    List.map evalExpr list |> String.join ""
