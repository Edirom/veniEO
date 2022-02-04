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

(: Set the path to the document :)
let $documentPath := '/Users/username/pathToResource/edirom_source_ID.xml'

(: Set the scale factor :)
let $scaleFactor := 2.985

let $doc := doc($documentPath)
for $zone in $doc//mei:facsimile//mei:zone
    
    (: Multiply all coordinate values with the scale factor :)
    let $ulxNew :=  round($zone/@ulx * $scaleFactor)
    let $ulyNew :=  round($zone/@uly * $scaleFactor)
    let $lrxNew :=  round($zone/@lrx * $scaleFactor)
    let $lryNew :=  round($zone/@lry * $scaleFactor)
    
    (: Replace all old coordinate values with the scaled coordinate values :)
    return 
        (
          replace value of node $zone/@ulx with $ulxNew,
          replace value of node $zone/@uly with $ulyNew,
          replace value of node $zone/@lrx with $lrxNew,
          replace value of node $zone/@lry with $lryNew
        )
