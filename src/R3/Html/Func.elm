module R3.Html.Func exposing (apply, bold, code, composeList, dict, italic, red)

import Dict exposing (Dict)
import Maybe.Extra


type alias AttributeList =
    List ( String, String )


type Func
    = FAttr AttributeList
    | FTag TagName
    | F (String -> String)


type FuncType
    = TAttr
    | TTag
    | TF


type alias FData =
    { name : String, body : String -> String }


type alias TagName =
    String


{-|

    > parse "[red.i.b test]" |> evalResult
    "<div><span style=font-weight:bold;font-style:italic;color:red;foo:bar >test</span></div>

-}
apply : Func -> String -> String
apply func str =
    case func of
        FAttr attributes ->
            applyAttributes attributes str

        FTag tagName ->
            tag tagName str

        F f ->
            f str


applyAttributes : AttributeList -> String -> String
applyAttributes attrList str =
    let
        attr =
            List.map (\( k, v ) -> k ++ ":" ++ v) attrList
                |> String.join ";"
    in
    tagWithStyle attr "span" str


compose : Func -> Func -> Maybe Func
compose f g =
    case ( f, g ) of
        ( FAttr ff, FAttr gg ) ->
            case gg == [ ( "*", "*" ) ] of
                True ->
                    FAttr ff |> Just

                False ->
                    FAttr (ff ++ gg) |> Just

        ( FTag ff, FTag gg ) ->
            case gg == "*" of
                True ->
                    FTag ff |> Just

                False ->
                    Nothing

        ( F ff, F gg ) ->
            Just (F (ff << gg))

        ( _, _ ) ->
            Nothing


typeOfFunc : Func -> FuncType
typeOfFunc func =
    case func of
        FAttr _ ->
            TAttr

        FTag _ ->
            TTag

        F _ ->
            TF


typeOfFuncList : List Func -> Maybe FuncType
typeOfFuncList funcList =
    let
        firstType =
            List.head funcList
                |> Maybe.map typeOfFunc
                |> Maybe.withDefault TTag
    in
    case List.all (\t -> t == firstType) (List.map typeOfFunc funcList) of
        True ->
            Just firstType

        False ->
            Nothing


composeList : List Func -> Maybe Func
composeList funcs =
    let
        id =
            case typeOfFuncList funcs of
                Just TAttr ->
                    idFAttr

                Just TTag ->
                    idFTag

                Just TF ->
                    idF

                Nothing ->
                    idFTag
    in
    List.foldl
        (\f acc -> Maybe.map2 compose f acc |> Maybe.Extra.join)
        (Just id)
        (List.map Just funcs)



-- FUNCTION DICT


dict : Dict String Func
dict =
    Dict.fromList
        [ ( "i", italic )
        , ( "b", bold )
        , ( "red", red )
        , ( "code", code )
        , ( "math", F (\x -> "$" ++ x ++ "$") )
        ]


idFAttr : Func
idFAttr =
    FAttr [ ( "*", "*" ) ]


idFTag : Func
idFTag =
    FTag "*"


idF : Func
idF =
    F identity


red : Func
red =
    FAttr [ ( "color", "red" ) ]


italic : Func
italic =
    FAttr [ ( "font-style", "italic" ) ]


bold : Func
bold =
    FAttr [ ( "font-weight", "bold" ) ]


code : Func
code =
    FTag "code"



-- HELPERS


tag : String -> String -> String
tag tag_ string =
    "<" ++ tag_ ++ ">" ++ string ++ "</" ++ tag_ ++ ">"


tagWithStyle : String -> String -> String -> String
tagWithStyle style tag_ string =
    "<" ++ tag_ ++ " style=" ++ style ++ " >" ++ string ++ "</" ++ tag_ ++ ">"
