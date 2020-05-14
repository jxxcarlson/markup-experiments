module M1.Parse exposing (Document, Element(..), parseDocument)

import Parser exposing (..)


type alias Document =
    List Element


type Element
    = Heading String
    | Subheading String
    | Paragraph (List String)


{-|

    parseDocument "|h foo\n\n|s bar\n\nyada\nyada\n\nfee\nfie\nfo!\n\n"
    --> Ok [Heading "foo\n",Subheading "bar\n",Paragraph ["yada\n","yada\n"],Paragraph ["fee\n","fie\n","fo!\n"]]

-}
parseDocument : String -> Result (List DeadEnd) Document
parseDocument str =
    run document str


document : Parser Document
document =
    many element


element : Parser Element
element =
    oneOf [ heading, subheading, paragraph ]


many : Parser a -> Parser (List a)
many p =
    loop [] (step p)


step : Parser a -> List a -> Parser (Step (List a) (List a))
step p vs =
    oneOf
        [ succeed (\v -> Loop (v :: vs))
            |= p
            |. spaces
        , succeed ()
            |> map (\_ -> Done (List.reverse vs))
        ]


heading : Parser Element
heading =
    succeed Heading
        |. symbol "|h"
        |. spaces
        |= line
        |. spaces


subheading : Parser Element
subheading =
    succeed Subheading
        |. symbol "|s"
        |. spaces
        |= line
        |. spaces


line : Parser String
line =
    getChompedString <|
        succeed ()
            |. chompIf (\c -> c /= '\n')
            |. chompWhile (\c -> c /= '\n')
            |. symbol "\n"


paragraph : Parser Element
paragraph =
    (succeed identity
        |= loop [] nextLine
        |. symbol "\n"
    )
        |> map Paragraph


type alias Par =
    List String


nextLine : Par -> Parser (Step Par Par)
nextLine revPar =
    oneOf
        [ succeed (\line_ -> Loop (line_ :: revPar))
            |= line
        , succeed (symbol "\n")
            |> map (\_ -> Done (List.reverse revPar))
        ]
