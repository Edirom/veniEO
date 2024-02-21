xquery version "3.1";
(:
 : Author: Dennis Ried, 2022
 : Update @n with new numbers; position() will be new @n
:)

declare default element namespace "http://www.music-encoding.org/ns/mei";

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";
declare namespace util = "http://exist-db.org/xquery/util";


let $sourceURI := '/db/apps/baudiData/sources/music/cantatas/baudi-01-8a00c113.xml'
let $docToUpdate := doc($sourceURI)
let $mdiv := $docToUpdate//mei:mdiv[@label='X']

for $part at $i in $mdiv//mei:part[not(@label="hornFrench.iv")]
    let $measures2Copy := $part//mei:measure[number(@label) gt 1][number(@label) lt 22]
    let $measure22 := $part//mei:measure[@label="22"]
    let $measure22N := $part//mei:measure[@label="22"]/@n
    
    let $measures2CopyModified := for $measure at $z in $measures2Copy
                                      let $measureN := $measure/@n/number() + count($measures2Copy) + 1
                                      let $measureLabel := $measure/@label/number() + 21
                                      let $measureID := concat('measure_', util:uuid())
                                      let $measureFacs := $measure/@facs
                                      return
                                          <measure n="{$measureN}" label="{$measureLabel}" xml:id="{$measureID}" facs="{$measureFacs}"/>
    let $add := <add>
                    {$measures2CopyModified}
                </add>
    
    return
        update insert $add following $measure22
