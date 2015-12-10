xquery version "1.0";
(: 
    @author Benjamin W. Bohl
:)

declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace edirom="http://www.edirom.de/ns/1.3";
declare namespace xlink="http://www.w3.org/1999/xlink";

import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

(: TODO
 : 
 : declare parameters instead of variables to submit values externally
 : concat value to check against mei:relation/@target from workID or expression and respective workFile uri
 :  :)

declare function local:unifyString($input){
    replace(functx:trim(normalize-space($input)),'(\p{Z}|&#160;|\W)+',' ')
};

declare function local:getNewMembers($collection, $idList, $group.name, $connection.name, $URIprefix){
    
    let $groupKey := local:unifyString($group.name)
    return
(:        $collection//mei:measure[ancestor::mei:mdiv[local:unifyString(@label) = $item/@key] and @n = $measureN]:)
    for $file in $collection
    let $file.name := util:document-name($file)
    where $file/mei:mei/@xml:id = $idList
    return (: path to id of measure in right mdiv with correct n :)
(:        string-join( :)
            for $measure in $file//mei:measure[ancestor::mei:mdiv[local:unifyString(@label) = $groupKey] and @n = $connection.name]
            return concat($URIprefix,$file.name,'#',data($measure/@xml:id))
(:        ):)
};
(: in use :)
declare variable $output := request:get-parameter('output','list');
declare variable $sourceIDs := request:get-parameter('sourceIDs', 'music_edition');
declare variable $cautious := request:get-parameter('cautious','false'); (: boolean true or false :)

let $sourceIDs := tokenize($sourceIDs,'_XX_')
let $cautious := if($cautious = 'true')then(true())else(false())

(: not yet in use :)

let $defaultLang := request:get-parameter('lang', 'de')
let $expressionID := 'TODO to get concordance for specific expression'

(: in use :)
let $workID := request:get-parameter('works', 'annotations.xml')
let $workDoc := collection('/db/contents/edition-74338556/works')//id($workID)

let $sourceColl := collection('/db/contents/edition-74338556/sources/?select=*.xml')
let $workSources := $sourceColl//mei:source[.//mei:relation/@target = 'xmldb:exist:///db/contents/edition-74338556/works/annotations.xml#annotations.xml_exp1']/root()/mei:mei
let $referenceSource := $workSources//mei:source[.//mei:title='Edition: Score' and .//mei:relation/@target = 'xmldb:exist:///db/contents/edition-74338556/works/annotations.xml#annotations.xml_exp1']/root()/mei:mei

let $plistPrefix := 'xmldb:exist:///db/contents/edition-74338556/sources/'

let $mdivs := ($sourceColl//mei:mdiv)
let $labels := for $item at $i in distinct-values(for $label in $mdivs//@label return local:unifyString($label))
               let $num :=number(string-join(functx:get-matches($item,'\d+')))
               order by $num
               return element item {
                   attribute n {$i},
                   attribute sort {$num},
                   attribute key {$item},
                   for $orig in $mdivs//@label
                   where  replace(functx:trim(normalize-space($orig)),'(\p{Z}|&#160;|\W)+',' ') = $item
                   return
                        element orig {
                            attribute source {$orig},
                            attribute sourceID {$orig/root()/mei:mei/@xml:id}
                            
                        }
               }
return 
    if (false())then(
        element root { $labels }
    )else
        
        
(:    element concordances {:)
(:            :)
(:        element concordance {:)
(:            attribute name {"Werkausgabe"},:)
(:            element groups {:)
(:                attribute label {"Satz"},:)
(:                for $item at $i in $labels:)
(:                let $sort :=number($item/@sort):)
(:                where $sort = 4 (: TODO pre-select by param :):)
(:                order by $sort:)
(:                return:)
(:(:                    element mdiv {attribute pos {$i}, attribute sort {$sort}, attribute label {$item/orig[1]/@source}}:):)
(:                    element group {:)
(:                        attribute name {$item/orig[1]/@source},:)
(:                        element connections{:)
(:                            attribute label {"Takt"},:)
(:                            for $measureN in distinct-values($mdivs[local:unifyString(@label) = $item/@key]//mei:measure/@n)(: TODO add testcase outputting first measure of each mov :):)
(:                            order by number($measureN):)
(:                            return:)
(:                                element connection{:)
(:                                    attribute name {$measureN},:)
(:                                    attribute plist {:)
(:                                        for $match in $sourceColl//mei:measure[ancestor::mei:mdiv[local:unifyString(@label) = $item/@key] and @n = $measureN]:)
(:                                        let $matchID := $match/@xml:id:)
(:                                        let $sourceID := $match/ancestor::mei:mei/@xml:id:)
(:                                        return concat($plistPrefix,$sourceID,'.xml#',$matchID)(:TODO parts:):)
(:                                    }:)
(:                                }:)
(:                        }:)
(:                    }:)
(:            }:)
(:        }:)
(:    }:)
 
for $conc in doc('xmldb:exist:///db/contents/edition-74338556/edition-favart.xml')//edirom:concordances/edirom:concordance[@name = 'Navigation by number &amp; bar']//edirom:group[position() gt 10](: gt 6 and position() lt 10 :)
let $group.name := data($conc/@name)
let $comment := comment {'<!-\-', current-dateTime(), 'added source(s) ',string-join($sourceIDs, ', ') ,' to connections via EdiromOnline_add2conc.xql, see above group ' , '-\->',replace(replace(serialize($conc),'<!--','<!-\\-'),'-->','-\\->')}
return(
(:    element root {:)
    if ( $cautious )
    then ( 
        update insert $comment following $conc
    ) else (),
    for $connection in $conc//edirom:connection
        let $connection.name := $connection/@name
        let $connection.plist := data($connection/@plist)
        let $newMembers := local:getNewMembers($sourceColl, $sourceIDs, $group.name, $connection.name, $plistPrefix)
        return(
            update value $connection/@plist with normalize-space(string-join(( $newMembers, $connection.plist),' '))
        )
(:    }:)
)    