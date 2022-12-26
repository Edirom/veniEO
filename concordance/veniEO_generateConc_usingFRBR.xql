xquery version "3.1";
(: 
    @author Nikolaos Beer
    @author Benjamin W. Bohl
    @author Dennis Ried (revision 2022)
:)

declare default element namespace "http://www.edirom.de/ns/1.3";

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

declare function functx:escape-for-regex($arg as xs:string?) as xs:string {
    
    replace($arg,
    '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))', '\\$1')
};

declare function functx:substring-after-last($arg as xs:string?, $delim as xs:string) as xs:string {
    
    replace($arg, concat('^.*', functx:escape-for-regex($delim)), '')
};

declare function local:getPlist($sourceColl as node()*, $measure as node(), $mdivLabel as xs:string) as xs:string {
    let $matchesScores := $sourceColl//mei:measure[ancestor::mei:mdiv[(@label eq $mdivLabel) and ./*[not(self::mei:parts)]] and (@n = $measure/@n)]
    let $matchesParts := $sourceColl//mei:part[1]//mei:measure[ancestor::mei:mdiv[(@label eq $mdivLabel) and ./*[self::mei:parts]] and (@n = $measure/@n)]
    let $plistItems := for $match in ($matchesScores | $matchesParts)
                         let $hasParts := exists($match/ancestor::mei:mdiv/mei:parts)
                         let $matchID := if($hasParts) then($match/ancestor::mei:mdiv/@xml:id) else($match/@xml:id)
                         let $sourceID := $match/ancestor::mei:mei/@xml:id
                         let $matchPartmdivID := $match/ancestor::mei:mdiv/string(@xml:id)
                         let $matchPartMeasureNo := $match/@n
                         let $sourceUri := document-uri($match/root())
                         order by $sourceUri
                         return
                             if($hasParts)
                             then(concat('xmldb:exist://',$sourceUri,'#measure_',$matchPartmdivID,'_',$matchPartMeasureNo))
                             else(concat('xmldb:exist://',$sourceUri,'#',$matchID))
    return
        string-join($plistItems, ' ') => normalize-space()
};

declare function local:getSources($work as node(), $editionDoc as node()) as node()* {
    let $workID := $work/string(@xml:id)
    let $workDoc := doc($work/@xlink:href)
    let $workNavItemsSources := $editionDoc//work/id($workID)//navigatorItem[contains(@targets, 'baudi-01-')]
    let $sourceColl := for $source in $workNavItemsSources
                       return doc($source/@targets)
    let $workSources := $sourceColl//mei:manifestation[.//mei:relation/@target[contains(., concat($workID, '.xml#', $workID, '_exp1'))]]/root()/mei:mei
    return
        $workSources
};

declare function local:getExpressions($work as node()) as node()* {
    doc(substring-after($work/@xlink:href,'xmldb:exist://'))//mei:expressionList/mei:expression
};

declare function local:getGroups($referenceSource as node(), $sourceColl as node()*){
    for $mdiv at $n in $referenceSource//mei:mdiv
       let $mdivLabel := $mdiv/string(@label)
       return
           element group {
               element names {
                   element name {
                       attribute xml:lang {'de'}, $mdivLabel
                   },
                   element name {
                       attribute xml:lang {'en'},
                       if (contains($mdivLabel, 'Nr.'))
                       then
                           concat('No. ', substring-after($mdivLabel, 'Nr. '))
                       else
                           ($mdivLabel)
                   }
               },
                element connections{
                   attribute label {"Takt"},
                   for $measure in $mdiv//mei:measure
                   order by number($measure/@n)
                   return
                       element connection{
                           attribute name {if ($measure/@label) then ($measure/@label) else ($measure/@n)},
                           attribute plist {local:getPlist($sourceColl, $measure, $mdivLabel)}
                       }
               }
           }
};

declare function local:generateConc($work as node(), $expression as node(), $referenceSource as node(), $sourceColl as node()*, $i as xs:int) as node() {
    let $concNames := for $title in $expression/mei:title
                        let $name := $title => normalize-space()
                        let $lang := $title/string(@xml:lang)
                        return
                            element name {
                                attribute xml:lang {$lang}, $name
                            }
    return
        element concordance {
            attribute name {'Expression_' || $i},
            element names {$concNames},
            element groups {
                attribute label {"movement"},
                element names {
                    element name {
                        attribute xml:lang {'de'}, 'Satz'
                    },
                    element name {
                        attribute xml:lang {'en'}, 'Movement'
                    }
                },
                local:getGroups($referenceSource, $sourceColl)
            }
        }
};

let $path2editionFile := '/db/apps/baudiData/editions/baudi-14-2b84beeb/edirom/baudi-14-2b84beeb.xml'
let $path2sources := '/db/apps/baudiData/sources/music'
let $refSourceID := 'baudi-01-bdfac5dd'

let $editionDoc := doc($path2editionFile)

for $work in $editionDoc//work
    let $sourceColl := local:getSources($work, $editionDoc)
    let $referenceSource := collection($path2sources)//mei:mei[@xml:id = $refSourceID]
    let $concordances := for $expression at $i in local:getExpressions($work)
                            return
                                local:generateConc($work, $expression, $referenceSource, $sourceColl, $i)

return
    <concordances xmlns="http://www.edirom.de/ns/1.3">
        {$concordances}
    </concordances>
(:    update replace $editionDoc//work[@xml:id = $workID]/concordances/concordance with $concordance:)
    
    (:xmldb:store('xmldb:exist:///db/contents/edition-rwa/resources/xml/concs/rwaVol_II-8/', $concFileName, $concordance):)