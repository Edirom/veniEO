xquery version "3.0";

(:  Generate MEI 3.0.0 file for new Music Work

    This is to be used in oXygen XML editor with Saxon-EE.
    Dennis Ried, 2018-05-28 :)

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace uuid = "java:java.util.UUID";
declare namespace saxon = "http://saxon.sf.net/";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

let $encoder := 'Dennis Ried'
let $encoderShort := 'dried'
let $encoderAnnot := '' (: Freitextfeld :)

(:  Please insert work title :)
let $workTitleMain := 'Am fernen Strand' (: Titel diplomatisch :)
let $workTitleSub := '' (: Untertitel diplomatisch :)
let $workTitleDesc := '' (: Beschreibung diplomatisch :)
let $workTitleMainAlt := 'The distand Strand' (: Alternativer Titel :)
let $workTitleSubAlt := '' (: Alternativer Untertitel :)
let $workTitleDescAlt := '' (: Alternative Beschreibung diplomatisch :)

let $workTitleUniformMainDE := 'Am fernen Strand' (: Titel standartisiert D :)
let $workTitleUniformSubDE := '' (: Untertitel standartisiert D :)
let $workTitleUniformDescDE := 'für Singstimme und Klavier' (: Beschreibung standartisiert D :)
let $workTitleUniformDescEN := 'for voice and piano' (: Beschreibung standartisiert GB :)
let $workLangUsage := 'D' (:values: D, GB, I, F:)

(: Persons :)
(:  Please insert responsibilities here. Leave missing reponsibilities empty.  :)
(:	If there is an ID missing use '%'. This will produce an invalid value that :)
(:	is easy to find. This practice does not have any dependencies to the rest  :)
(:	of the document															   :)
let $composer := 'Ludwig Baumann'
let $composerID := '5e3ed698'
let $arranger := ''
let $arrangerID := ''
let $lyricist := 'Willi Birger'
let $lyricistID := 'f7902fb2'
let $funder := ''

(: Widmung :)
let $respDedPers := ''
let $respDedPersID := ''
let $respDedCorp := ''
let $respDedCorpID := ''
let $respDedText := '' (: Widmungstext :)

(:	key, tempo, meter, instrument information	:)
let $TempoUnit := '' (: Metronomangabe Notenwert :)
let $TempoUnitDots := '' (: Metronomangabe Notenwert punktiert:)
let $TempoValue := '' (: Metronomangabe Zahlwert :)
let $Tempo := 'Stürmisch bewegt.' (: Tempoangabe (text):)
let $MeterCount := '4'
let $MeterUnit := '4'
let $MeterSym := 'common' (: C-Zeichen common = 4/4; cut = 2/2 :) 
let $KeyPName := 'd' (: english note names :)
let $KeyAccid := '' (: s for sharp or f for flat :)
let $KeyMode := 'major' (: minor, major, dorian,... :)
let $Instruments := ('Singstimme','Klavier') (: Insert diplomatic instrument names as list.  :)

(:	If the work has Text set 'true':)
let $workHasSongText := 'false' (: if 'true' the songtext section will be generated :)

(: ************************************************************************** :)
(: ******************* xml:id for elements. Do not change ******************* :)
(: ************************************************************************** :)
let $workID as xs:string := concat('baudi-02-', substring(fn:string(uuid:randomUUID()), 1, 8))
let $workTitleID := concat($workID, '-title')
let $workTitleMainID := concat($workID, '-titleMain')
let $workTitleSubID := concat($workID, '-titleSub')
let $workTitleDescID := concat($workID, '-titleDesc')
let $workTitleAltID := concat($workID, '-titleAlt')
let $workTitleMainAltID := concat($workID, '-titleMainAlt')
let $workTitleSubAltID := concat($workID, '-titleSubAlt')
let $workTitleDescAltID := concat($workID, '-titleDescAlt')
let $workTitleUniformDEID := concat($workID, '-titleUniformDE')
let $workTitleUniformMainDEID := concat($workID, '-titleUniformMainDE')
let $workTitleUniformSubDEID := concat($workID, '-titleUniformSubDE')
let $workTitleUniformDescDEID := concat($workID, '-titleUniformDescDE')
let $workTitleUniformENID := concat($workID, '-titleUniformEN')
let $workTitleUniformMainENID := concat($workID, '-titleUniformMainEN')
let $workTitleUniformSubENID := concat($workID, '-titleUniformSubEN')
let $workTitleUniformDescENID := concat($workID, '-titleUniformDescEN')
let $composerIDconcat := concat('baudi-04-', $composerID)
let $arrangerIDconcat := concat('baudi-04-', $arrangerID)
let $lyricistIDconcat := concat('baudi-04-', $lyricistID)
let $respDedPersIDconcat := concat('baudi-04-', $respDedPersID)
let $respDedCorpIDconcat := concat('baudi-05-', $respDedCorpID)
let $composerElementID := concat($workID, '-composer')
let $arrangerElementID := concat($workID, '-arranger')
let $lyricistElementID := concat($workID, '-lyricist')
let $respStmtElementID := concat($workID, '-respStmtDed')
let $respDedPersElementID := concat($workID, '-dedicateePers')
let $respDedCorpElementID := concat($workID, '-dedicateeCorp')
let $dedicationIDconcat := concat($workID, '-dedication')

(: ************************************************************************** :)
(: ***************************** File content. ****************************** :)
(: ************************************************************************** :)
let $workFileName := concat($workID, '.xml')
let $doc := .
let $schema := <?xml-model href="../resources/schema/mei-all-4-dev.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
let $content :=  <mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="4.0.0" xml:id="{$workID}">
	<meiHead>
		<fileDesc>
			<titleStmt>
			<title type="uniform" xml:lang="de" xml:id="{$workTitleUniformDEID}">
			<titlePart type="main" xml:lang="de" xml:id="{$workTitleUniformMainDEID}">{$workTitleUniformMainDE}</titlePart>
			<titlePart type="sub" xml:lang="de" xml:id="{$workTitleUniformSubDEID}">{$workTitleUniformSubDE}</titlePart>
			<titlePart type="desc" xml:lang="de" xml:id="{$workTitleUniformDescDEID}">{$workTitleUniformDescDE}</titlePart>
			</title>
			<title type="uniform" xml:lang="en" xml:id="{$workTitleUniformENID}">
			<titlePart type="desc" xml:lang="en" xml:id="{$workTitleUniformDescENID}">{$workTitleUniformDescEN}</titlePart>
			</title>
			</titleStmt>
			<pubStmt>
				<respStmt>
					<persName>
						<ref target="baudi-04-1d680f20.xml#dried">Dennis Ried</ref>
					</persName>
					<resp>This file was generated for the Baumann Digital project (BauDi). Files and
						data from the catalogue of works are a part of the PhD thesis of Dennis
						Ried. This data stock will be published after the PhD thesis ist
						finished.</resp>
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
					<accessRestrict n="1">While the PhD thesis of Dennis Ried is still in progress,
						this file and its data are not allowed to be used, shared or adapt in any
						way. After the PhD thesis is published this work will be accessable unter
						the licence of CC-BY-NE-SA. For using parts of this data or infrastructure
						please get in contact an we will find a solution <ref target="mailto:ried-musikforschung@mail.de">ried-musikforschung@mail.de</ref>
					</accessRestrict>
				</availability>
				<date isodate="{current-date()}">File generated.</date>
			</pubStmt>
		</fileDesc>
		<encodingDesc>
			<editorialDecl>
				<p/>
			</editorialDecl>
			<samplingDecl>
				<p decls="Kodierungsrichtlinien">
					<ref target="workEncodingGuidelines.xml">Richtlinien zur Kodierung der
						Quellen</ref>
				</p>
			</samplingDecl>
		</encodingDesc>
		<workList>
			<work>
                               <title type="origin" xml:id="{$workTitleID}">
			<titlePart type="main" xml:id="{$workTitleMainID}">{$workTitleMain}</titlePart>
			<titlePart type="sub" xml:id="{$workTitleSubID}">{$workTitleSub}</titlePart>
			<titlePart type="desc" xml:id="{$workTitleDescID}">{$workTitleDesc}</titlePart>
			</title>
			{if($workTitleMainAlt='') then() else(
			<title type="alt" xml:id="{$workTitleAltID}">
			<titlePart type="mainAlt" xml:id="{$workTitleMainAltID}">{$workTitleMainAlt}</titlePart>
			<titlePart type="subAlt" xml:id="{$workTitleSubAltID}">{$workTitleSubAlt}</titlePart>
			<titlePart type="descAlt" xml:id="{$workTitleDescAltID}">{$workTitleDescAlt}</titlePart>
			</title>)}
                                <composer xml:id="{$composerIDconcat}"><ref target="{concat($composerID,'.xml')}">{$composer}</ref></composer>
                                <arranger xml:id="{$arrangerIDconcat}"><ref target="{concat($arrangerID,'.xml')}">{$arranger}</ref></arranger>
                                <lyricist xml:id="{$lyricistIDconcat}"><ref target="{concat($lyricistID,'.xml')}">{$lyricist}</ref></lyricist>
                                <funder>{$funder}</funder>
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
				
				<creation/>
				<history/>
				<langUsage>
					<head>In der Quelle verwendete Sprache(n)</head>
					<language label="ger">deutsch</language>
				</langUsage>
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
				<audience/>
				<contents>
					<contentItem/>
					<!-- Enthaltenes (z.B. außermusikalisches: Literatur, (gesell.) Themen, o.ä.). Enthaltene Werke können hier oder in der relationList angegeben werden. -->
				</contents>
				<context/>
				<classification>
					<head/>
					<termList>
						<term type="setting" analog="{concat('#',$workTitleUniformDescDEID)}"/>
						<term type="workGroup">Gruppenzuordnung</term>
						<term type="genre">Gattung</term>
						<term type="keyword">Schlagwort</term>
						<!-- z.B. Streich-Ensemble -->
					</termList>
				</classification>
		        <!--		
		          <componentList>
					<!-/- Gibt es untergeordnete Werke, werden hier die Einzel-Werke verlinkt.
						Die Quellen werden dann den entsprechenden Werken zugeordnet. -/->
						<manifestation target="#ID"/>
				  </componentList>
				-->
				<relationList>
					<!-- Hier werden die zugehörigen Quellen verlinkt -->
					<relation rel="hasEmbodiment" target="#ID"/>
				</relationList>
			</work>
		</workList>
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
                    <music/>
                  </mei>
                        
return
($schema,$content)