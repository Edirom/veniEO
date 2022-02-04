xquery version "3.0";

(:  Generate MEI 4.0.0 file for new musical source (manuscript score)

    This is to be used in oXygen XML editor with Saxon-EE.
    Dennis Ried, 2017-11-20 for BauDi
    modified to MEI 4 on 2018-10-17:)

(: ToDo: Better way to insert information about instrumentation :)

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace uuid = "java:java.util.UUID";
declare namespace saxon = "http://saxon.sf.net/";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare option saxon:output "method=xml";
declare option saxon:output "media-type=text/xml";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "indent=yes";


let $encoder := 'Dennis Ried'
let $encoderShort := 'dried'
let $encoderAnnot := '' (: Freitextfeld :)

(:  Please insert source title :)
let $sourceTitleMain := 'Heiliges Feuer.' (: Titel diplomatisch :)
let $sourceTitleSub := '' (: Untertitel diplomatisch :) (:Den Gefallenen zum Gedächtnis, den Trauernden zum Trost:)
let $sourceTitleDesc := 'Für 1 höhere Singstimme mit Klavierbegleitung' (: Beschreibung diplomatisch :)

let $sourceTitleUniformMainDE := 'Heiliges Feuer' (: Titel standartisiert :)
let $sourceTitleUniformSubDE := '' (: Untettitel standartisiert :)
let $sourceTitleUniformDescDE := 'für hohe Singstimme' (: Beschreibung standartisiert :)

(:  Please insert source identifier :)
let $sourceRismID := '?????'
let $sourceRepoID := 'M 308,1' (: Repository Shelfmark :)
let $sourceRepoSiglum := 'D-KA' (:Official Library Siglum following RISM:)
let $sourceRepoName := 'Badische Landesbibliothek Karlsruhe'
let $sourceLangUsage := 'D' (:values: D, GB, I, F:)

(:	Paper dimension and orientation :)
let $sourceDimensionsHeigth := '334' (: unit [mm]:)
let $sourceDimensionsWidth := '255' (: unit [mm]:)
let $sourceExtentOrient := '1' (: 1 for 'portrait', 2 for 'landscape':)
let $sourceExtentCover := 'true' (: '' oder 'true' :)
let $sourceExtentFolium := '3' (: ohne Buchdeckel, nur Blätter :)
let $sourceExtentPagesWithoutCover := '3' (: Nur Mit Noten beschriebene Seiten :)
let $sourceExtentPagination := 'arabic' (: e.g. none, irregular, arabic :)

(:	Describes the type of score used to represent a musical composition	:)
(:	(e.g., short score, full score, condensed score, close score, etc.)	:)
let $sourceScoreFormat := 'song score'

(:	description of the physical medium	:)
let $sourceStamp := 'Badische Landesbibliothek/Karlsruhe'
let $sourceStampLayer := '1r'
let $sourceStampPos := 'S' (: cardinal direction :)
let $sourcePaperTypeNote := ''
let $sourcePaperTypeNoteLayer := '1r'
let $sourcePaperTypeNotePos := 'SE' (: cardinal direction :)
let $sourcePlateNumber := 'ANDRÉ 17352'
let $sourceCopyright:= 'Verlag &amp; Eigentum für alle Länder von Johann André, Offenbach a. Main.'
let $sourcePhysMedium := 'Gedruckt, Gebunden (Klebebindung).'
let $sourceWatermark := ''

(: Handschriftliche Vermerke :)
let $sourceHandNote1 := '[um 1920]'
let $sourceHandNote1Type := 'Vermerk' (: BiblVermerk, AuffVermerk, Schlussvermerk, Vermerk :)
let $sourceHandNote1Layer := '1r'
let $sourceHandNote1Pos := 'S'
let $sourceHandNote1Medium := 'Bleistift'

let $sourceHandNote2 := 'M 308, 1./2.'
let $sourceHandNote2Type := 'BiblVermerk'
let $sourceHandNote2Layer := '1r'
let $sourceHandNote2Pos := 'N'
let $sourceHandNote2Medium := 'Bleistift'

let $sourceHandNote3 := 'M 308, 1'
let $sourceHandNote3Type := 'BiblVermerk'
let $sourceHandNote3Layer := '1v'
let $sourceHandNote3Pos := 'C'
let $sourceHandNote3Medium := 'Bleistift'

let $sourceHandNote4 := 'Z'
let $sourceHandNote4Type := 'BiblVermerk'
let $sourceHandNote4Layer := '1v'
let $sourceHandNote4Pos := 'S'
let $sourceHandNote4Medium := 'Bleistift'

let $sourceHandNoteFreitext := ''
(: Persons :)
(:  Please insert responsibilities here. Leave missing reponsibilities empty.  :)
(:	If there is an ID missing use '%'. This will produce an invalid value that :)
(:	is easy to find. This practice does not have any dependencies to the rest  :)
(:	of the document															   :)
let $composer := 'Ludwig Baumann'
let $composerID := '5e3ed698'
let $arranger := ''
let $arrangerID := ''
let $lyricist := 'Heinz Stadelmann'
let $lyricistID := 'ff23e58e'
(: Widmung :)
let $respDedPers := 'Karl Kamann'
let $respDedPersID := 'fb2d8c1a'
let $respDedCorp := ''
let $respDedCorpID := ''
let $respDedText := 'Herrn Opernsänger Karl Kamann freundlichst gewidmet.' (: Widmungstext :)

(:	key, tempo, meter, instrument information	:)
let $TempoUnit := '' (: Metronomangabe Notenwert :)
let $TempoUnitDots := '' (: Metronomangabe Notenwert punktiert:)
let $TempoValue := '' (: Metronomangabe Zahlwert :)
let $Tempo := 'Schwungvoll, doch nicht zu schnell.' (: Tempoangabe (text):)
let $MeterCount := '3'
let $MeterUnit := '4'
let $MeterSym := '' (: C-Zeichen common = 4/4; cut = 2/2 :) 
let $KeyPName := 'e' (: english note names :)
let $KeyAccid := 'f' (: s for sharp or f for flat :)
let $KeyMode := 'major' (: minor, major, dorian,... :)
let $Instruments := ('Singstimme','Klavier') (: Insert diplomatic instrument names as list.  :)
let $ambitusLow := 'es1'
let $ambitusHigh := 'f2'

(:	If the source has Text set 'true':)
let $sourceHasSongText := 'true' (: if 'true' the songtext section will be generated :)

(: ************************************************************************** :)
(: ******************* xml:id for elements. Do not change ******************* :)
(: ************************************************************************** :)
let $sourceID as xs:string := concat('baudi-01-', substring(fn:string(uuid:randomUUID()), 1, 8))
let $sourceTitleUniformDEID := concat($sourceID, '-titleUniformDE')
let $sourceTitleUniformMainDEID := concat($sourceID, '-titleUniformMainDE')
let $sourceTitleUniformSubDEID := concat($sourceID, '-titleUniformSubDE')
let $sourceTitleUniformDescDEID := concat($sourceID, '-titleUniformDescDE')
let $sourceTitleID := concat($sourceID, '-title')
let $sourceTitleMainID := concat($sourceID, '-titleMain')
let $sourceTitleSubID := concat($sourceID, '-titleSub')
let $sourceTitleDescID := concat($sourceID, '-titleDesc')
let $composerIDconcat := concat('baudi-04-', $composerID)
let $arrangerIDconcat := concat('baudi-04-', $arrangerID)
let $lyricistIDconcat := concat('baudi-04-', $lyricistID)
let $respDedPersIDconcat := concat('baudi-04-', $respDedPersID)
let $respDedCorpIDconcat := concat('baudi-05-', $respDedCorpID)
let $composerElementID := concat($sourceID, '-composer')
let $arrangerElementID := concat($sourceID, '-arranger')
let $lyricistElementID := concat($sourceID, '-lyricist')
let $respStmtElementID := concat($sourceID, '-respStmtDed')
let $respDedPersElementID := concat($sourceID, '-dedicateePers')
let $respDedCorpElementID := concat($sourceID, '-dedicateeCorp')
let $dedicationIDconcat := concat($sourceID, '-dedication')
let $sourcePhysMediumID := concat($sourceID, '-physMedium')

(: ************************************************************************** :)
(: ***************************** File content. ****************************** :)
(: ************************************************************************** :)
let $sourceFileName := concat($sourceID, '.xml')
let $doc := .
let $schema := <?xml-model href="../../resources/schema/mei-all-4-dev.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
let $content := <mei
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns="http://www.music-encoding.org/ns/mei"
	meiversion="4.0.0"
	xml:id="{$sourceID}">
	<meiHead>
		<fileDesc>
			<titleStmt>
				 <title type="uniform" xml:lang="de" xml:id="{$sourceTitleUniformDEID}">
               <titlePart type="main" xml:lang="de" xml:id="{$sourceTitleUniformMainDEID}"
               >{$sourceTitleUniformMainDE}</titlePart> <titlePart type="sub" xml:lang="de"
               xml:id="{$sourceTitleUniformSubDEID}">{$sourceTitleUniformSubDE}</titlePart> <titlePart type="desc" xml:lang="de"
               xml:id="{$sourceTitleUniformDescDEID}"
               >{$sourceTitleUniformDescDEID}</titlePart> </title>
			</titleStmt>
			<pubStmt>
				<respStmt>
					<persName>
						<ref
							target="baudi-04-1d680f20.xml#dried">{$encoder}</ref>
					</persName>
					<resp>This file was generated for the Baumann Digital project (BauDi). Files and data from the catalogue of works are a part of the PhD thesis of Dennis Ried. This data stock will be published after the PhD thesis ist finished.</resp>
				</respStmt>
				<address>
					<postCode>76133</postCode>
					<settlement>Karlsruhe</settlement>
					<country>Germany</country>
				</address>
				<address>
					<postCode>67165</postCode>
					<settlement>Waldsee</settlement>
					<country>Germany</country>
				</address>
				<availability>
					<accessRestrict
						n="1">While the PhD thesis of Dennis Ried is still in progress, this file and its data are not allowed to be used, shared or adapt in any way. After the PhD thesis is published this work will be accessable unter the licence of CC-BY-NE-SA.
						For using parts of this data or infrastructure please get in contact an we will find a solution <ref
							target="mailto:ried-musikforschung@mail.de">ried-musikforschung@mail.de</ref></accessRestrict>
				</availability>
				<date
					isodate="{substring(string(current-date()), 1, 10)}"/>
			</pubStmt>
	   <!-- <sourceDesc>
			<source>
			<head/>
			<locus/>
			<bibl/>
			</source>
			</sourceDesc> -->
		</fileDesc>
		<encodingDesc>
			<editorialDecl><p/></editorialDecl>
			<samplingDecl>
				<p
					decls="Kodierungsrichtlinien">
					<ref
						target="SourceEncodingGuidelines.xml">Richtlinien zur Kodierung der Quellen</ref>
				</p>
			</samplingDecl>
		</encodingDesc>
		<workList>
			<work>
			<title analog="{concat('#',$sourceTitleID)}"/>
				{
					if ($KeyAccid = '')
					then
						(<key
							pname="{$KeyPName}"
							mode="{$KeyMode}"/>)
					else
						(<key
							pname="{$KeyPName}"
							accid="{$KeyAccid}"
							mode="{$KeyMode}"/>)
				}
				{if ($MeterSym = '')
				then (
				<meter
					count="{$MeterCount}"
					unit="{$MeterUnit}"/>)
					else (<meter
					count="{$MeterCount}"
					unit="{$MeterUnit}" sym="{$MeterSym}"/>)
				}
				{
					if ($TempoUnit = '' and not($TempoValue = ''))
					then
						(<tempo
							mm="{$TempoValue}">{$Tempo}</tempo>)
					else
						if ($TempoValue = '' and (not($TempoUnit = '') and not($TempoUnitDots = '')))
						then
							(<tempo
								mm.unit="{$TempoUnit}"
								mm.dots="{$TempoUnitDots}">{$Tempo}</tempo>)
						else
							if ($TempoValue = '' and not($TempoUnit = ''))
							then
								(<tempo
									mm.unit="{$TempoUnit}">{$Tempo}</tempo>)
							else
								if ($TempoUnitDots = '' and (not($TempoUnit = '') or not($TempoValue = '')))
								then
									(<tempo
										mm.unit="{$TempoUnit}"
										mm="{$TempoValue}">{$Tempo}</tempo>)
								else
									if ($TempoUnit = '' and $TempoValue = '' and $TempoUnitDots = '')
									then
										(<tempo>{$Tempo}</tempo>)
									else
										(<tempo
											mm.unit="{$TempoUnit}"
											mm.dots="{$TempoUnitDots}"
											mm="{$TempoValue}">{$Tempo}</tempo>)
				}
				<incip/>
				<perfMedium>
					<perfResList>
						{
							for $perfRes in $Instruments
							let $perfResLabel := $perfRes
							return
								<perfRes>{$perfResLabel}</perfRes>
						
						}
					</perfResList>
				</perfMedium>
			</work>
		</workList>
			<manifestationList>
				<manifestation class="#ms">
				<head/>
					{
						if ($sourceRismID = '')
						then
							()
						else
							(
							<identifier
								type="rism">{$sourceRismID}</identifier>
							)
					}
					{
						if ($sourceRepoID = '' and $sourceRepoSiglum = '')
						then
							()
						else
							(
							<identifier
								type="{$sourceRepoSiglum}">{$sourceRepoID}</identifier>
							)
					}
					<titleStmt>
					<title xml:id="{$sourceTitleID}">
						<titlePart
							type="main"
							xml:id="{$sourceTitleMainID}">{$sourceTitleMain}</titlePart>
						<titlePart
							type="sub"
							xml:id="{$sourceTitleSubID}">{$sourceTitleSub}</titlePart>
							<titlePart
							type="desc"
							xml:id="{$sourceTitleDescID}">{$sourceTitleDesc}</titlePart>
							</title>
						<composer
							xml:id="{$composerElementID}">
							<ref
								target="{concat('persons.xml#', $composerIDconcat)}">{$composer}</ref>
						</composer>
						<arranger
							xml:id="{$arrangerElementID}">
							{
								if ($arranger = '')
								then
									()
								else
									(<ref
										target="{concat('persons.xml#', $arrangerIDconcat)}">{$arranger}</ref>)
							}
						</arranger>
						<lyricist
							xml:id="{$lyricistElementID}">
							{
								if ($lyricist = '')
								then
									()
								else
									(<ref
										target="{concat('persons.xml#', $lyricistIDconcat)}">{$lyricist}</ref>)
							}
						</lyricist>
						<respStmt
							xml:id="{$respStmtElementID}">
							{
								if ($respDedPers = '')
								then
									()
								else
									(
									<persName
										role="dedicatee"
										xml:id="{$respDedPersElementID}">
										<ref
											target="{concat('persons.xml#', $respDedPersIDconcat)}">{$respDedPers}</ref></persName>
									)
							}
							{
								if ($respDedCorp = '')
								then
									()
								else
									(<corpName
										role="dedicatee"
										xml:id="{$respDedCorpElementID}">
										<ref
											target="{concat('institutions.xml#', $respDedCorpIDconcat)}">{$respDedCorp}</ref></corpName>)
							}
						</respStmt>
					</titleStmt>
					<physDesc>
						<p
							decls="creation">
							<!--	<date
								type="creation"
								subtype="sure"
								isodate="0000"/> -->
						</p>
						<titlePage>
							<!-- Hier die Titelseite codieren (diplomatische Wiedergabe!) -->
							<p
								decls="titlePage">
								{$sourceTitleMain}<lb/>
								{$sourceTitleSub}<lb/>
								{$sourceTitleDesc}<lb/>
								{$composer}<lb/>
								{$arranger}<lb/>
								{$lyricist}<lb/>
								{$respDedText}
							</p>
						</titlePage>
						<dimensions
							label="height"
							unit="mm">{$sourceDimensionsHeigth}</dimensions>
						<dimensions
							label="width"
							unit="mm">{$sourceDimensionsWidth}</dimensions>
						<extent
							label="orientation">{
								if ($sourceExtentOrient = '1') then
									('portrait')
								else
									if ($sourceExtentOrient = '2') then
										('landscape')
									else
										()
							}</extent>
						{
							if ($sourceExtentCover = '') then
								()
							else
								(
								<extent
									label="cover">{$sourceExtentCover}</extent>)
						}
						<extent
							label="folium"
							unit="folium">{$sourceExtentFolium}</extent>
						<extent
							label="pages"
							unit="page">{$sourceExtentPagesWithoutCover}</extent>
						<extent
							label="pagination">{
								if ($sourceExtentPagination = '') then
									()
								else
									($sourceExtentPagination)
							}</extent>
						<scoreFormat>{$sourceScoreFormat}</scoreFormat>
						{
							if ($sourceWatermark = '') then
								()
							else
								(
								<watermark
									label="watermark">{$sourceWatermark}</watermark>
								)
						}
						<handList>
							<hand
								label="{$sourceHandNote1Pos} {$sourceHandNote1Layer} {$sourceHandNote1Type}"
								medium="{$sourceHandNote1Medium}">{$sourceHandNote1}</hand>
							{
								if ($sourceHandNote2 = "") then
									()
								else
									(
									<hand
										label="{$sourceHandNote2Pos} {$sourceHandNote2Layer} {$sourceHandNote2Type}"
										medium="{$sourceHandNote2Medium}">{$sourceHandNote2}</hand>
									)
							}
							{
								if ($sourceHandNote3 = "") then
									()
								else
									(
									<hand
										label="{$sourceHandNote3Pos} {$sourceHandNote3Layer} {$sourceHandNote3Type}"
										medium="{$sourceHandNote3Medium}">{$sourceHandNote3}</hand>
									)
							}
							{
								if ($sourceHandNote4 = "") then
									()
								else
									(
									<hand
										label="{$sourceHandNote4Pos} {$sourceHandNote4Layer} {$sourceHandNote4Type}"
										medium="{$sourceHandNote4Medium}">{$sourceHandNote4}</hand>
									)
							}
							{
								if ($sourceHandNoteFreitext = "") then
									()
								else
									(
									<hand
										label="freitext">{$sourceHandNoteFreitext}</hand>
									)
							}
						</handList>
						<condition
							n="1">
							<date
								isodate="{substring(string(current-date()), 1, 10)}"
								type="desc"
								resp="{$encoderShort}"/>
							<!-- <p decls="statusReport">Zustandsbeschreibung</p> -->
						</condition>
						<physMedium
							xml:id="{$sourcePhysMediumID}">{$sourcePhysMedium}
						</physMedium>
					</physDesc>
					<physLoc>
						<repository>
							<corpName
								label="{$sourceRepoSiglum}">{$sourceRepoName}</corpName>
							<identifier
								type="shelfmark">{$sourceRepoID}</identifier>
						</repository>
					</physLoc>
					<history>
						<!-- <eventList/> -->
					</history>
					<langUsage>
						<!-- u.U. Beschreibung welcher Teil der Quelle welche Sprache verwendet -->
						{
							if ($sourceLangUsage = 'D')
							then
								(
								<language
									label="dt"/>
								)
							else
								if ($sourceLangUsage = 'GB')
								then
									(
									<language
										label="en"/>
									)
								else
									if ($sourceLangUsage = 'I')
									then
										(
										<language
											label="it"/>
										)
									else
										if ($sourceLangUsage = 'F')
										then
											(
											<language
												label="fr"/>
											)
										else
											()
						}
					</langUsage>
					<contents>
						<!-- Weitere Beschreibung des physischen Mediums -->
						<!--	<p>
							<list
								label="quires">
								<head>Lagenordnung</head>
								<li
									n="1">1. Lage</li>
							</list>
						</p> -->
					</contents>
					<biblList>
						<!-- Erwähnungen der Quelle -->
						<!--<bibl type="letter"/>
						<bibl type="announcement"/>
						<bibl type="notice"/>-->
					</biblList>
					<notesStmt>
						<!-- Weitere Anmerkungen des Beschreibers -->
						<annot
							n="1"
							when="{substring(string(current-date()), 1, 10)}"
							label="{$encoderShort}">{$encoderAnnot}</annot>
						{
							if ($sourceStamp = '') then
								()
							else
								(<annot
									plist="stamp {$sourceStampPos}-oriented {$sourceStampLayer}"
									corresp="{concat('#', $sourcePhysMediumID)}">{$sourceStamp}</annot>)
						}
						{
							if ($sourcePaperTypeNote = '') then
								()
							else
								(<annot
									plist="paperTypeNote {$sourcePaperTypeNotePos}-oriented"
									corresp="{concat('#', $sourcePhysMediumID)}">{$sourcePaperTypeNote}</annot>)
						}
					</notesStmt>
					<classification>
						<termList>
							<term
								type="source">Manuskript</term>
							<term
								type="setting"
								xml:lang="de"><ptr
									target="{concat('#', $sourceTitleUniformDescDEID)}"/></term>
							<term
								type="workGroup"/>
							<term
								type="genre"/>
						</termList>
					</classification>
					<!--
					<componentList>
               <head>Beschreibung einzelner Stimmen oder untergeordneten Quellen.</head>
               <manifestation class="#ms">
                  <identifier/>
                  <physDesc>
                     <extent/>
                  </physDesc>
               </manifestation>
               <manifestation class="#pr"/>
            </componentList>
            -->
					<relationList/>
				</manifestation>
			</manifestationList>
			<extMeta xmlns:tei="http://www.tei-c.org/ns/1.0"/> 
		<revisionDesc>
			<change
				n="0"
				label="dried"
				isodate="2017-04-01">
				<changeDesc>
					<p>Initializing the project</p>
				</changeDesc>
			</change>
			<change
				n="1"
				isodate="{substring(string(current-date()), 1, 10)}"
				label="{$encoderShort}">
				<changeDesc>
					<p>File generated by generateSourceMsScore.xql</p>
				</changeDesc>
			</change>
		</revisionDesc>
	</meiHead>
	<music>
		<facsimile/>
		<body>
		<mdiv/>
		</body>
	</music>
</mei>

let $result := <root>{$schema,$content}</root>
(: Output :)
return
    put($result,concat('../../BauDi/baudi-contents/sources/music/',$sourceID,'.xml'))