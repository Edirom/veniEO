xquery version "3.1";
(:~
 : Author: Dennis Ried, 2018 and 2022
 : For use on local machine
 : Oxygen-Preferences: Update 'on'; Tree 'linked'; Backup 'on'
 :)

declare default element namespace "http://www.edirom.de/ns/1.3";

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";

(:declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";:)

let $sourceID := 'edirom_edition_ID'

let $docToUpdate := doc(concat('insertValues/',$sourceID,'.xml'))
let $docVertaktoidClean := doc(concat('vertaktoid/clean/',$sourceID,'-clean.xml'))

let $surfacesVertaktoid := $docVertaktoidClean//mei:surface
let $mdivsVertaktoid := $docVertaktoidClean//mei:body/mei:mdiv

(: TODO: Updates the surfaces, but simply adds the mdivs :)

return
	(
	insert nodes $mdivsVertaktoid as last into $docToUpdate//mei:body,
	for $i in 1 to count($docToUpdate//mei:surface)
		let $zonesVertaktoid := $docVertaktoidClean//mei:surface[$i]/mei:zone
		return
    		insert nodes $zonesVertaktoid as last into $docToUpdate//mei:surface[$i]
    )
