xquery version "1.0";
(: 
    @author Nikolaos Beer
    @author Benjamin W. Bohl
    @author Dennis Ried
:)


declare default element namespace "http://www.edirom.de/ns/1.3";

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";


declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

declare function functx:escape-for-regex
($arg as xs:string?) as xs:string {
    
    replace($arg,
    '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))', '\\$1')
};

declare function functx:substring-after-last
($arg as xs:string?,
$delim as xs:string) as xs:string {
    
    replace($arg, concat('^.*', functx:escape-for-regex($delim)), '')
};

(: TODO
 : 
 : declare parameters instead of variables to submit values externally
 : concat value to check against mei:relation/@target from workID or expression and respective workFile uri
 :  :)

(: not yet in use :)
(:let $defaultLang := request:get-parameter('lang', 'de')
let $expressionID := 'TODO to get concordance for specific expression':)

(: in use :)
(:let $workID := request:get-parameter('works', 'edirom_work_61b5ce81-4667-4f8a-8438-f7937e6d99db'):)

let $editionDoc := doc('/db/apps/edirom/edition-example/content/ediromEditions/edirom_edition_example.xml')

for $work in $editionDoc//work
(:for $work in $editionDoc//work:)

let $workID := $work/@xml:id/fn:string()
let $workDoc := collection('/db/apps/edirom/edition-example/content/works')//id($workID)


let $workNavSourceColl := $editionDoc//work[./@xml:id = $workID]//navigatorCategory//navigatorItem[contains(@targets, 'edirom_source_') or contains(@targets, 'edirom_edition_')]
let $workNavEdition := $editionDoc//work[./@xml:id = $workID]//navigatorCategory//navigatorItem[contains(@targets, 'edirom_edition_')]
let $workNavEditionID := substring-before(functx:substring-after-last($workNavEdition/@targets/fn:string(), '/'), '.xml')

let $sourceColl := for $source in $workNavSourceColl
            let $sourceID := substring-before(functx:substring-after-last($source/@targets/fn:string(), '/'), '.xml')
            return
                collection('/db/apps/edirom/edition-example/content')//mei:mei[@xml:id = $sourceID]

let $workSources := $sourceColl//mei:source[.//mei:relation/@target[contains(., concat($workID, '.xml#', $workID, '_exp1'))]]/root()/mei:mei


let $referenceSource := collection('/db/apps/edirom/edition-example/content/editions')//mei:mei[@xml:id = $workNavEditionID]

let $plistPrefix := 'xmldb:exist:///db/apps/edirom/edition-example/content/'

let $concFileName := concat('ediromMusicConc_', $workID, '.xml')

let $concordance := element concordance {
    attribute name {"Konkordanz"},
    element names {
        element name {
            attribute xml:lang {'de'}, 'Haupt-Konkordanz'
        },
        element name {
            attribute xml:lang {'en'}, 'Main Concordance'
        }
    },
    element groups {
        attribute label {"Song"},
        element names {
            element name {
                attribute xml:lang {'de'}, 'Lied'
            },
            element name {
                attribute xml:lang {'en'}, 'Song'
            }
        },
        for $mdiv at $n in $referenceSource//mei:mdiv
(:        where $n = 11:)
        
        return
            element group {
                element names {
                    element name {
                        attribute xml:lang {'de'}, string($mdiv/@label)
                    },
                    element name {
                        attribute xml:lang {'en'},
                        if (contains($mdiv/@label, 'Nr.'))
                        then
                            concat('No. ', substring-after(string($mdiv/@label), 'Nr. '))
                        else
                            (string($mdiv/@label))
                    }
                },
                
                 element connections{
                                                attribute label {"Takt"},
                                                for $measure in $mdiv//mei:measure
                                                order by number($measure/@n)
                                                return
                                                    element connection{
                                                        attribute name {if ($measure/@label) then ($measure/@label) else ($measure/@n)},
                                                        attribute plist {
                                                            for $match in $sourceColl//mei:measure[ancestor::mei:mdiv[contains(@label, $mdiv/@label) and ./*[not(self::mei:parts)]] and @n = $measure/@n]
                                                            let $matchID := $match/@xml:id
                                                            let $sourceID := $match/ancestor::mei:mei/@xml:id
                                                            let $sourceTypeCollectionName := if (starts-with($match/root()/mei:mei/@xml:id, 'edirom_edition_'))
                                                            then ('editions')
                                                            else ('source')
                                                            return concat($plistPrefix,$sourceTypeCollectionName,'/',$sourceID,'.xml#',$matchID)
                                                            (:,
                                                            for $matchPart in $sourceColl//mei:part[1]//mei:measure[ancestor::mei:mdiv[contains(@label, $mdiv/@label) and ./*[self::mei:parts]] and @n = $measure/@n]
                                                            (\:let $matchIDPart := $matchPart/@xml:id:\)
                                                            let $matchPartmdivID := $matchPart/ancestor::mei:mdiv/@xml:id
                                                            let $matchPartMeasureNo := $matchPart/@n
                                                            let $sourceIDPart := $matchPart/ancestor::mei:mei/@xml:id
                                                            let $sourceTypeCollectionName := if ( $matchPart/root()//mei:sourceDesc/mei:source/mei:classification/text() = 'MusPr')
                                                            then ('prints')
                                                            else if ( $matchPart/root()//mei:sourceDesc/mei:source/mei:classification/text() = 'MusMs')
                                                            then ('manuscripts')
                                                            else if ( $matchPart/root()//mei:sourceDesc/mei:source/mei:classification/text() = 'MusEd')
                                                            then ('editions')
                                                            else ()
                                                            return concat($plistPrefix,$sourceTypeCollectionName,'/',$sourceIDPart,'.xml#measure_',$matchPartmdivID,'_',$matchPartMeasureNo) (\: Fehler bei $matchPartmdivID :\):)
                                                        }
                                                    }
                                            }
            }
    }
}


return
    $concordance

    (:update insert $concordance preceding $editionDoc//work[@xml:id = $workID]/concordances//concordance[1]:)
    
    (:xmldb:store('xmldb:exist:///db/contents/edition-rwa/resources/xml/concs/rwaVol_II-8/', $concFileName, $concordance):)