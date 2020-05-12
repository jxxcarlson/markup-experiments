module R2.LaTeX.Func exposing (apply, applyMacro, bold, compose, composeList, dict, italic, red)

import Dict exposing (Dict)


type alias MacroName =
    String


type Func
    = FMacro (List MacroName)


{-|

    > import R2.LaTeX.Func exposing(..)

    > bold
    FMacro ["textbf"] : Func

    > apply bold "this"
    "\\textbf{this}"

    > apply (compose bold italic) "this"
    "\\textbf{\\textit{this}} "

    > apply (composeList [ bold,  italic, red]) "this"
    "\\red{\\textit{\\textbf{this}}}" : String

-}
apply : Func -> String -> String
apply func str =
    case func of
        FMacro macroName ->
            applyMacro macroName str


applyMacro : List MacroName -> String -> String
applyMacro macroNames_ str =
    let
        macroNames =
            List.reverse macroNames_

        firstMacro =
            List.head macroNames |> Maybe.withDefault "id"

        otherMacros =
            List.drop 1 macroNames

        apply_ : MacroName -> String -> String
        apply_ macroName_ str_ =
            "\\" ++ macroName_ ++ "{" ++ str_ ++ "}"
    in
    List.foldl (\macro_ acc -> apply_ macro_ acc) (apply_ firstMacro str) otherMacros ++ " "


{-|

    > compose red bold
    FMacro ["red","textbf"] : Func

-}
compose : Func -> Func -> Func
compose f g =
    case ( f, g ) of
        ( FMacro ff, FMacro gg ) ->
            FMacro (ff ++ gg)


{-|

    > composeList [ bold,  italic, red]
    FMacro ["textbf","textit","red"]

-}
composeList : List Func -> Func
composeList funcs =
    List.foldl (\f acc -> compose acc f) id funcs
        |> funcDropFirst


funcDropFirst : Func -> Func
funcDropFirst (FMacro args) =
    FMacro (List.drop 1 args)


dropLast : List a -> List a
dropLast list =
    list
        |> List.reverse
        |> List.drop 1
        |> List.reverse



-- FUNCTION DICT


dict : Dict String Func
dict =
    Dict.fromList [ ( "id", id ), ( "i", italic ), ( "b", bold ), ( "red", red ) ]


id : Func
id =
    FMacro [ "id" ]


red : Func
red =
    FMacro [ "red" ]


italic : Func
italic =
    FMacro [ "textit" ]


bold : Func
bold =
    FMacro [ "textbf" ]
