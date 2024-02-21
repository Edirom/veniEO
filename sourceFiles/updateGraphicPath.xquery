xquery version "3.1";
(:
 : @author Dennis Ried, 2022
 : Simple replacement of attribute value
 : for use on local machine
:)

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";

declare option saxon:output "method=xml";
declare option saxon:output "media-type=text/xml";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "indent=no";

let $collection := collection('../../../BauDi/baudi-data/sources/music/cantatas?select=*.xml;recurse=yes')

for $document in $collection
    let $doc := doc(document-uri($document))
    for $surface in $doc//mei:facsimile/mei:surface
        
        let $graphic := $surface/mei:graphic
        let $graphicTarget := $surface/mei:graphic/@target
        let $graphicXmlBase := $surface/mei:graphic/@xml:base
        
        return
            if($graphicXmlBase)
            then(
                    replace value of node $graphicTarget with $graphicXmlBase,
                    delete node $graphicXmlBase
                )
            else()
