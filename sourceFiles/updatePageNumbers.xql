xquery version "1.0";
(:
 : Author: Dennis Ried, 2018
 : Update @n with new numbers; position() will be new @n
:)

declare default element namespace "http://www.edirom.de/ns/1.3";

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

let $docToUpdate := doc('/db/apps/pathToResource/edirom_source_ID.xml')
let $surfaces := $docToUpdate//mei:facsimile/mei:surface

for $surface in $surfaces
    let $pageNumOld := $surface/@n
    let $pageNumNew := count($surface/preceding-sibling::*)+1.

return
    update value $pageNumOld with $pageNumNew
