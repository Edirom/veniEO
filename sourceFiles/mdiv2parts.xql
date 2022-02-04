xquery version "3.0";

(: for use in eXist-db :)

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace util = "http://exist-db.org/xquery/util";

(:let $sourceCollection := collection('xmldb:exist:///db/contents/edition-rwa/sources/music')

for $source in $sourceCollection
where $source//mei:parts
    return
   $source:)

let $sourceURI := '/db/apps/pathToResource/edirom_source_ID.xml'
let $doc := doc($sourceURI)
let $mdivSearch := ('mdiv1','mdiv2')
let $instrVoiceLabels := for $instrVoice in $doc//mei:instrVoice
                            let $instrVoiceLabel := $instrVoice/@label
                            return
                                $instrVoiceLabel
let $instrVoiceIDs := for $instrVoice in $doc//mei:instrVoice
                        let $instrVoiceID := $instrVoice/@xml:id
                        return
                            $instrVoiceID

return
    
    <body>
        {
            for $mdiv in $mdivSearch
            let $mdviID := concat('edirom_mdiv_', util:uuid())
            let $mdivs := $doc//mei:mdiv[substring-after(./@label, ' | ') = $mdiv]
            (:let $mdivs := $doc//mei:mdiv/@label:)
            return
                
                <mdiv
                    xml:id="{$mdviID}"
                    label="{$mdiv}">
                    <parts>
                        {
                            for $instrVoiceLabel at $pos in $instrVoiceLabels
                            let $sectionSearch := $mdivs[substring-before(@label, ' | ') = $instrVoiceLabel]//mei:section
                            return
                                <part
                                    xml:id="{concat('edirom_part_', util:uuid())}"
                                    label="{$instrVoiceLabel}">
                                    <staffDef
                                        decls="{concat('#', $instrVoiceIDs[$pos])}"/>
                                    {$sectionSearch}
                                </part>
                        }
                    </parts>
                </mdiv>
        }
    </body>