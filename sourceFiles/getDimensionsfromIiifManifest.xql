xquery version "3.1";
(:
    BauDi, Dennis Ried, 2022
    This script calls the dimensions of an image from its iiif manifest
:)
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace functx = "http://www.functx.com";
declare namespace http = "http://expath.org/ns/http-client";
declare namespace util = "http://exist-db.org/xquery/util";
declare namespace fn="http://www.w3.org/2005/xpath-functions";

let $collection := collection('/db/apps/baudiData/sources/music/cantatas')
for $doc in $collection

let $surfaces := $doc//*:surface

for $surface at $n in $surfaces
    let $graphic := $surface/*:graphic
    let $graphicWidth := $surface/@width
    let $graphicHeight := $surface/@height
    let $response :=
        <response>{
            let $url := $graphic/(@target|@url) || '/info.json'
            let $request := http:send-request(<http:request href="{$url}" method="GET" override-media-type="application/json"/>)
            return
                $request
        }</response>
    let $convertData := util:binary-to-string($response/text())
    let $heightNew := parse-json($convertData)?height
    let $widthNew := parse-json($convertData)?width
    
    return
        (
           if($graphicHeight)
           then(update replace $graphicHeight with $heightNew)
           else(update insert attribute height {$heightNew} into $graphic),
           if($graphicWidth)
           then(update replace $graphicWidth with $widthNew)
           else(update insert attribute lrx {$widthNew} into $graphic)
        )
