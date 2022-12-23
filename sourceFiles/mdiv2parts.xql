xquery version "3.1";

(: for use in eXist-db :)
(: update to mei 5.0.0-dev :)
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace util = "http://exist-db.org/xquery/util";
import module namespace functx = "http://www.functx.com";


let $sourceURI := '/db/apps/baudiData/sources/music/cantatas/baudi-01-58dcf426.xml'
let $doc := doc($sourceURI)
let $mdivSearch :=  ('vorspiel')
let $perfResLabels := for $perfRes in $doc//mei:perfRes
                            let $perfResLabel := $perfRes/@label
                            return
                                $perfResLabel
let $perfResIDs := for $perfRes in $doc//mei:perfRes
                        let $perfResID := $perfRes/@xml:id
                        return
                            $perfResID

return
    
    <body>
        {
            for $mdiv in $mdivSearch
            let $mdviID := concat('mdiv_', util:uuid())
            let $mdivs := $doc//mei:mdiv[if(contains(@label, ' | ')) then(substring-after(@label, ' | ') = $mdiv) else(true())]
            return
                
                <mdiv
                    xml:id="{$mdviID}"
                    label="{$mdiv}">
                    <parts>
                        {
                            for $perfResLabel at $pos in $perfResLabels
                            let $sectionSearch := $mdivs[functx:substring-before-if-contains(@label, ' | ') = $perfResLabel]//mei:section
                            return
                                <part label="{$perfResLabel}" xml:id="{concat('edirom_part_', util:uuid())}">
                                    
                                    <staffDef n="{$pos}" lines="5" decls="{concat('#', $perfResIDs[$pos])}"/>
                                    {$sectionSearch}
                                </part>
                        }
                    </parts>
                </mdiv>
        }
    </body>