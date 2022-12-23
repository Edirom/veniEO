xquery version "3.1";
(:
 : Dennis Ried, 2022
 : Modify position values of zones in sources
 : for use on local machine
:)

declare default element namespace "http://www.edirom.de/ns/1.2";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";

declare option saxon:output "method=xml";
declare option saxon:output "media-type=text/xml";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "indent=no";

let $collection := collection('../../../BauDi/baudi-data/sources/music/cantatas?select=*.xml;recurse=yes')

(:let $doc := doc($documentPath):)
for $document in $collection
   where $document/id('baudi-01-bdfac5dd')
   let $doc := doc(document-uri($document))
   for $surface in $doc//mei:facsimile/mei:surface
       let $add2HeightBottom := 40
       let $add2HeightTop := 0
       let $add2WidthRight := 0
       let $add2WidthLeft := 0
        for $zone in $surface//mei:zone
            (: Multiply all coordinate values with the scale factor :)
            let $ulxNew :=  round($zone/@ulx + $add2WidthLeft)
            let $ulyNew :=  round($zone/@uly + $add2HeightTop)
            let $lrxNew :=  round($zone/@lrx + $add2WidthRight)
            let $lryNew :=  round($zone/@lry + $add2HeightBottom)
            
            (: Replace all old coordinate values with the scaled coordinate values :)
            return
                (
                  replace value of node $zone/@ulx with $ulxNew,
                  replace value of node $zone/@uly with $ulyNew,
                  replace value of node $zone/@lrx with $lrxNew,
                  replace value of node $zone/@lry with $lryNew
                )
