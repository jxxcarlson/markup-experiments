module M1.Render exposing (renderDocument, renderElements)

import M1.Parse as Parse exposing (Element(..))


renderElements : List Element -> String
renderElements elementList =
    elementList
        |> List.map renderElement
        |> String.join "\n\n"


renderDocument : String -> String
renderDocument content =
    case Parse.parseDocument content of
        Ok ast ->
            renderElements ast

        _ ->
            "Error"


renderElement : Element -> String
renderElement element =
    case element of
        Paragraph content ->
            html "p" (String.join "" content)

        Heading content ->
            html "h1" content

        Subheading content ->
            html "h2" content


html tag content =
    "<" ++ tag ++ ">" ++ content ++ "</" ++ tag ++ ">"
