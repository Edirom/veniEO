xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace functx="http://www.functx.com";

declare option saxon:output "method=xml";
declare option saxon:output "media-type=text/xml";
declare option saxon:output "omit-xml-declaration=yes";
(:declare option saxon:output "indent=yes";:)

declare function functx:if-absent
  ( $arg as item()* ,
    $value as item()* )  as item()* {

    if (exists($arg))
    then $arg
    else $value
 } ;
 
 declare function functx:replace-multi
  ( $arg as xs:string? ,
    $changeFrom as xs:string* ,
    $changeTo as xs:string* )  as xs:string? {

   if (count($changeFrom) > 0)
   then functx:replace-multi(
          replace($arg, $changeFrom[1],
                     functx:if-absent($changeTo[1],'')),
          $changeFrom[position() > 1],
          $changeTo[position() > 1])
   else $arg
 } ;
 
    let $edition := 'rwaVol_II-7'
    let $contentsBasePath := '/Users/driedlokal/Repositories/rwa/contents/'
    let $doc := doc(concat($contentsBasePath, 'resources/xml/concs/', $edition, '/noSourceConcordances.xml'))
    let $lieder := for $lied in $doc//liedEdition
                    return
                        $lied
    let $workTitles := for $lied in $doc//liedEdition
                    let $workTitle := $lied//workTitle/text()
                    return
                        $workTitle
    let $musicSourceCollection := collection(concat($contentsBasePath, 'sources/music?select=*.xml;recurse=yes'))        
               
    for $work at $pos in distinct-values($workTitles)
    
    let $workFileTitle := fn:replace(fn:replace(fn:replace(fn:replace($work, '\. ', '_'), '/', '_'), ', ', '_'), ' ', '_')
    
    let $concFileName := concat('concLied_', $workFileTitle, '.xml')
    
    let $concordance := <concordance name="Lied-Verse" title="{$workFileTitle}">
                            <groups label="Lied">
                                {for $lied at $i in $lieder
                                    let $liedTitle := $lied/liedTitle
                                    let $liedSearchTitle := $liedTitle
                                    (:let $liedSearchTitle := if(contains($liedTitle, 'Nr.'))
                                                                        then (substring-after(substring-after($liedTitle, 'Nr. '), ' '))
                                                                        else ($liedTitle):)
                                    let $editionID := fn:string($lied//source/@id[contains(., 'rwa_edition')])
                                    let $editionMdivID := $lied/@id
                                    where matches($lied//workTitle, $work)  
                                    return 
                                        <group name="{$liedTitle}">
                                            {
                                            let $sourceConcordance := for $source in $lied//source
                                                                        let $sourceID := fn:string($source/@id)
                                                                        order by $source/@n descending
                                                                        return
                                                                            $sourceID
                                            let $lineConnection := for $editionTextLine in doc(concat($contentsBasePath, 'sources/music/editions/II_07/', $editionID, '.xml'))//mei:mdiv[@xml:id = $editionMdivID]//mei:l[not(@label = 'title')]
                                                                    let $editionTextLineNo := $editionTextLine/@n
                                                                    let $editionTextLineLabel := if ($editionTextLine/@label)
                                                                                                   then ($editionTextLine/@label)
                                                                                                   else ()
                                                                    let $musicLineParticipants := for $sourceParticipant in $sourceConcordance
                                                                                                    let $lineParticipant := if(starts-with($sourceParticipant, 'edirom_') or starts-with($sourceParticipant, 'rwa_'))
(:                                                                                                                            then('Test'):)
                                                                                                                            then ($musicSourceCollection/mei:mei[@xml:id = $sourceParticipant]//mei:mdiv[contains(@label, $liedTitle)]//mei:l[@n = $editionTextLineNo]/@xml:id)

                                                                                                                            else if (starts-with($sourceParticipant, 'mri_txtTempl'))
(:                                                                                                                            then ('Doch!'):)
                                                                                                                            then (doc(concat($contentsBasePath, 'sources/text/templates/', $sourceParticipant, '.xml'))//tei:text//tei:l[@n = (if(contains($editionTextLineLabel, '-')) then(substring-after($editionTextLineLabel, '-')) else($editionTextLineLabel))]/@xml:id)
                                                                                                                            else()
                                                                                                    let $participant := concat($sourceParticipant, '#', string-join(for $p in $lineParticipant return $p, '+'))
                                                                                                    return
                                                                                                        $participant
                                                                    order by $editionTextLineNo
                                                                    return 
                                                                        <connection name="{if ($editionTextLineLabel) then ($editionTextLineLabel) else('-')}" plist="{reverse($musicLineParticipants)}"/>
                                                return
                                                    $lineConnection
                                            }
                                </group>
                                }
                            </groups>
                </concordance>
    where $pos = 11
    
    return
(:    $musicSourceCollection[mei:mei/@xml:id = 'edirom_source_c884e707-d908-4471-84a3-e47461a2a0b3']:)
        $concordance
(:        $workFileTitle:)
(:        xmldb:store('xmldb:exist:///db/contents/edition-rwa/resources/xml/concs/rwaVol_II-7/', $concFileName, $concordance):)