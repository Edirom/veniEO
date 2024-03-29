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

declare function functx:contains-any-of( $arg as xs:string?, $searchStrings as xs:string* ) as xs:boolean {

   some $searchString in $searchStrings
   satisfies contains($arg,$searchString)
 } ;

declare function local:getPlist($sourceColl as node()*, $measure as node(), $mdivLabel as xs:string) as xs:string {
    let $matchesScores := $sourceColl//mei:measure[ancestor::mei:mdiv[(@label eq $mdivLabel) and ./*[not(self::mei:parts)]] and (@n = $measure/@n)]
    let $matchesParts := $sourceColl//mei:part[1]//mei:measure[ancestor::mei:mdiv[(@label eq $mdivLabel) and ./*[self::mei:parts]] and (@n = $measure/@n)]
    (: for $part in $parts: resolve multiRests, dann ganzer Part weiterreichen! Am besten mit neuen @n. Reicht das für den ersten Part?:)
    (: gleiches für scores:)
    (: return: <mei><mdiv><parts/></mdiv></mei> (virtuell mit den benötigten IDs) :)
    (:let $matchesScoresMultiRestResolved := for $match in $matchesScores[.//mei:multiRest]
                                             let $matchID := $match/@xml:id
                                             let $matchLabel := $match/number(@label)
                                             let $multiRestNum := $match//mei:multiRest/@num
                                             for $each at $n in 2 to $multiRestNum
                                                let $multiRestResolvedLabel := $matchLabel + $n
                                                return
                                                   <measure label="{$multiRestResolvedLabel}" xml:id="{$matchID}" xmlns="http://www.music-encoding.org/ns/mei"/>:)
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

declare function local:getSources($work as node(), $expression as node(), $editionDoc as node()) as node()* {
    let $workID := $work/string(@xml:id)
    let $workDoc := doc($work/@xlink:href)
    let $workNavItemsSources := $editionDoc//work/id($workID)//navigatorItem[functx:contains-any-of(@targets, ('baudi-01-','baudi-14-'))]
    let $sourceColl := for $source in $workNavItemsSources
                       return doc($source/@targets)
    let $expressionID := $expression/@xml:id
    let $workExprSources := $sourceColl//mei:manifestation[.//mei:relation/@target[contains(., concat($workID, '.xml#', $expressionID))]]/ancestor::mei:mei
    let $workSources := $sourceColl//mei:manifestation[.//mei:relation/@target[contains(., concat($workID, '.xml'))]]/ancestor::mei:mei
    return
        $workExprSources
        (:if($workExprSources)
        then($workExprSources)
        else($workSources):)
};

declare function local:getExpressions($work as node()) as node()* {
    doc(substring-after($work/@xlink:href,'xmldb:exist://'))//mei:expressionList/mei:expression
};

declare function local:getGroups($referenceSource as node(), $sourceColl as node()*){
    for $mdiv at $n in $referenceSource//mei:mdiv
(:       where $n = 11:)
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
            attribute name {'expression_' || format-number($i,'000')},
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

(: XXXX update this variables XXXX :)

let $path2editionFile := '/db/apps/baudiData/editions/baudi-14-2b84beeb/edirom/baudi-14-2b84beeb.xml'
let $path2sources := '/db/apps/baudiData/sources/music'
let $path2editionSources := '/db/apps/baudiData/editions/baudi-14-2b84beeb'
(: Give one reference source per expression! Can be the same. :)
let $refSourceIDs := ('baudi-01-bdfac5dd','baudi-01-bdfac5dd','baudi-01-bdfac5dd','baudi-01-bdfac5dd')

let $output := 'update' (:prossible values: 'print' or 'update':)

(: XXXX END: update this variables XXXX :)


let $editionDoc := doc($path2editionFile)

for $work in $editionDoc//work
    let $concordances := for $expression at $i in local:getExpressions($work)
                            let $sourceColl := local:getSources($work, $expression, $editionDoc)
                            let $referenceSource := (collection($path2sources) | collection($path2editions))//mei:mei[@xml:id = $refSourceIDs[$i]]
                            let $checkNoOfExprAndRefSources := count($refSourceIDs) eq count(local:getExpressions($work))
                            return
                                if ($checkNoOfExprAndRefSources and exists($referenceSource))
                                then(local:generateConc($work, $expression, $referenceSource, $sourceColl, $i))
                                else if ($checkNoOfExprAndRefSources and not(exists($referenceSource)))
                                then(<error>{'The reference source ' || $refSourceIDs[$i] || ' does not exist!'}</error>)
                                else(<error>{'There are ' || count(local:getExpressions($work)) || ' expressions, but ' || count($refSourceIDs) || ' reference sources!'}</error>)

    let $concordances := <concordances xmlns="http://www.edirom.de/ns/1.3">{$concordances}</concordances>

return
    if ($output = 'print')
    then($concordances)
    else if ($output = 'update')
    then(update replace $editionDoc//work[@xml:id = $work/@xml:id]/concordances with $concordances)
    else('Output option "' || $output || '" unknown!')
