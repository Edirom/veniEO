xquery version "3.0";
(:
 : Nikolaos Beer, 2015
 : Dennis Ried, 2022 (updated)
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
let $documentPath := '../../../BauDi/baudi-data/sources/music/cantatas/baudi-01-9d4b9769.xml'

(:let $doc := doc($documentPath):)
for $document in $collection
   let $doc := doc(document-uri($document))
   for $surface in $doc//mei:facsimile/mei:surface
       
       let $graphicWidth := $surface/mei:graphic/@width
       let $graphicHeight := $surface/mei:graphic/@height
       let $widthNew := $surface/@lrx
       let $widthOld := $graphicWidth
       let $heightNew := $surface/@lry
       let $heightOld := $graphicHeight
       (: Calculate scale factors :)
       let $scaleFactorWidth := ($widthNew div $widthOld)
       let $scaleFactorHeight := ($heightNew div $heightOld)
       
       return
       (
           for $zone in $surface//mei:zone
               (: Multiply all coordinate values with the scale factor :)
               let $ulxNew :=  round($zone/@ulx * $scaleFactorWidth)
               let $ulyNew :=  round($zone/@uly * $scaleFactorHeight)
               let $lrxNew :=  round($zone/@lrx * $scaleFactorWidth)
               let $lryNew :=  round($zone/@lry * $scaleFactorHeight)
               
               (: Replace all old coordinate values with the scaled coordinate values :)
               return
                   (
                     replace value of node $zone/@ulx with $ulxNew,
                     replace value of node $zone/@uly with $ulyNew,
                     replace value of node $zone/@lrx with $lrxNew,
                     replace value of node $zone/@lry with $lryNew
                   ),
           replace value of node $graphicWidth with string($widthNew),
           replace value of node $graphicHeight with string($heightNew)
       )
