module R2.Func exposing (apply, bold, composeList, dict, italic, red)

import Dict exposing (Dict)


type alias AttributeList =
    List ( String, String )


type Func
    = FAttr AttributeList


{-|

    > parse "[red.i.b test]" |> evalResult
    "<div><span style=font-weight:bold;font-style:italic;color:red;foo:bar >test</span></div>

-}
apply : Func -> String -> String
apply func str =
    case func of
        FAttr attributes ->
            applyAttributes attributes str


applyAttributes : AttributeList -> String -> String
applyAttributes attrList str =
    let
        attr =
            List.map (\( k, v ) -> k ++ ":" ++ v) attrList
                |> String.join ";"
    in
    tagWithStyle attr "span" str


compose : Func -> Func -> Func
compose f g =
    case ( f, g ) of
        ( FAttr ff, FAttr gg ) ->
            FAttr (ff ++ gg)


composeList : List Func -> Func
composeList funcs =
    List.foldl (\f acc -> compose f acc) id funcs



-- FUNCTION DICT


dict : Dict String Func
dict =
    Dict.fromList [ ( "id", id ), ( "i", italic ), ( "b", bold ), ( "red", red ) ]


id : Func
id =
    FAttr [ ( "*", "*" ) ]


red : Func
red =
    FAttr [ ( "color", "red" ) ]


italic : Func
italic =
    FAttr [ ( "font-style", "italic" ) ]


bold : Func
bold =
    FAttr [ ( "font-weight", "bold" ) ]


tagWithStyle : String -> String -> String -> String
tagWithStyle style tag_ string =
    "<" ++ tag_ ++ " style=" ++ style ++ " >" ++ string ++ "</" ++ tag_ ++ ">"
