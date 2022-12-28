xquery version "3.1";
(:
 : Author: Dennis Ried, 2022
 : Update @n with new numbers; position() will be new @n
:)

declare default element namespace "http://www.edirom.de/ns/1.3";

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

let $collection:= collection('/db/apps/baudiData/sources/music/cantatas')

for $doc at $n in $collection
    let $uri := document-uri($doc)
    let $mdivs := $doc//mei:mdiv
    for $mdiv at $i in $mdivs
        let $mdivLabel := $mdiv/@label
        let $measures := $mdiv//mei:measure
        for $measure in $measures
            let $measureNo := $measure/@label
            let $measureNoNext := $measure/following-sibling::mei:measure[1]/@label
            let $measureRange := (number($measureNoNext) - number($measureNo))
            let $multiRest := <staff xmlns="http://www.music-encoding.org/ns/mei">
                                <layer>
                                   <multiRest num="{$measureRange}"/>
                                </layer>
                              </staff>
            
            where $measureRange gt 1
            return
                update insert $multiRest into $measure
