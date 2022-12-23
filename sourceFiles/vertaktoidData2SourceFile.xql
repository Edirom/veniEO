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

declare option saxon:output "method=xml";
declare option saxon:output "media-type=text/xml";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "indent=no";

let $docToUpdate := doc('../../../BauDi/baudi-data/sources/music/cantatas/baudi-01-bdfac5dd.xml')
let $docVertaktoidClean := doc('../../../../Downloads/ed-ka2.xml')

let $surfacesVertaktoid := $docVertaktoidClean//mei:surface (:[number(@n) gt 98]:)
let $surfacesDocToUpdate := $docToUpdate//mei:surface (:[number(@n) gt 40]:)
let $mdivsVertaktoid := $docVertaktoidClean//mei:mdiv
let $mdivsDocToUpdate := $docToUpdate//mei:mdiv

return
	(
	for $i in 1 to count($mdivsVertaktoid)
		let $mdivVertaktoid := $mdivsVertaktoid[$i]
		return
    		replace node $mdivsDocToUpdate[$i] with $mdivVertaktoid,
	for $i in 1 to count($surfacesDocToUpdate)
		let $zonesVertaktoid := $surfacesVertaktoid[$i]/mei:zone
		return
    		insert nodes $zonesVertaktoid as last into $surfacesDocToUpdate[$i]
    )
