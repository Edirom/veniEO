xquery version "3.0";

(:  convert csv to xml
    Dennis Ried, 2020-07-10 :)
declare default element namespace "http://www.music-encoding.org/ns/mei";
declare namespace uuid = "java:java.util.UUID";
declare namespace mei = "http://www.music-encoding.org/ns/mei";

import module namespace functx = "http://www.functx.com" at "../../../BauDi/baudiResources/data/libraries/functx.xqm";

let $csvInput := unparsed-text('../../../BauDi/baudiWorks/data/BLB-new.csv')
let $lines := functx:lines($csvInput)

let $xml-output :=  <table>
                        {
                            for $line at $i in $lines
                               let $cells := tokenize($line, ';')
                               return
                                   <row n="{$i}">
                                       {
                                           for $cell at $n in $cells
                                           return
                                           <cell n="{$n}">{normalize-space($cell)}</cell>
                                       }
                                   </row>
                        }
                    </table>
   
let $rows := $xml-output//row

for $row at $pos in $rows
    let $fassung := if($row/cell[2]/string() !='')then(true())else(false())
    let $titleMain := $row/cell[3]/string()
    let $titleSort := $row/cell[4]/string()
    let $titleSub := $row/cell[6]/string()
    let $opusNo := $row/cell[5]/string()
    let $IdPartString := substring(fn:string(uuid:randomUUID()), 1, 8)
    let $composer := if($row/cell[7]/string() = 'Ludwig Baumann')
                     then(<persName auth="baudi-04-5e3ed698">Ludwig Baumann</persName>)
                     else($row/cell[7]/string())
    let $arranger := if($row/cell[9]/string() = 'Ludwig Baumann')
                     then(<persName auth="baudi-04-5e3ed698">Ludwig Baumann</persName>)
                     else()
    let $lyricist := if(contains($row/cell[8]/string(),'lied'))
                     then($row/cell[8]/string())
                     else(<persName>{$row/cell[8]/string()}</persName>)
    let $MeterCount := $row/cell[12]/string()
    let $MeterUnit := $row/cell[13]/string()
    let $MeterSym := if($row/cell[14]/string() = 'true') then('common') else('')
    let $meter := if ($MeterSym = '')
        		  then (<meter count="{$MeterCount}" unit="{$MeterUnit}"/>)
        		  else (<meter count="{$MeterCount}" unit="{$MeterUnit}" sym="{$MeterSym}"/>)
    let $key := <key pname="{functx:substring-before-if-contains($row/cell[10]/string(),'-')}"
                     accid="{if(contains($row/cell[10]/string(),'-'))
                             then('f')
                             else()}"
                     mode="{$row/cell[11]/string()}"/>
    let $tempo := $row/cell[24]/string()
    let $perfRess := for $perfRes in tokenize($row/cell[29],',')
                            let $auth := switch($perfRes)
                                          case 'S' return 'soprano'
                                          case 'A' return 'alto'
                                          case 'T' return 'tenor'
                                          case 'B' return 'bass'
                                          case 'Org' return 'organ'
                                          default return $perfRes
                            return
                                <perfRes auth="{$auth}"/>
    
    let $relatedWork := $row/cell[1]
    let $publisher := 'Hugo Kuntz'
    let $pubDate := $row/cell[19]/string()
    let $pubPlace := 'Karlsruhe in Baden'
    let $printer := $row/cell[28]/string()
    let $plateNum := <plateNum n="{$row/cell[18]/string()}">{$row/cell[17]/string()}</plateNum>
    let $height := $row/cell[26]/string()
    let $width := $row/cell[25]/string()
    let $pages := $row/cell[27]/string()
    let $folium := $row/cell[31]/string()
    let $pagination := $row/cell[32]/string() 
    let $dedication := $row/cell[20]/string()
    let $annotPerf := <annot type="performance">{$row/cell[23]/string()}</annot>
    
    let $shelfmark := $row/cell[33]/string()
    let $perfMedium := $row/cell[29]/string()
    let $source := <mei xmlns="http://www.music-encoding.org/ns/mei"
                        xmlns:xlink="http://www.w3.org/1999/xlink"
                        meiversion="4.0.0"
                        xml:id="baudi-01-{$IdPartString}">
                   	  <meiHead>
                   		    <fileDesc>
                   			      <titleStmt>
                   				        <title type="uniform" xml:lang="de"> 
                                              <titlePart type="main" xml:lang="de" xml:id="baudi-01-{$IdPartString}-titleUniMainDE">{$titleMain}</titlePart> 
                                           </title>
                   			      </titleStmt>
                                   <pubStmt>
                                      <availability>recorded</availability>
                                   </pubStmt>
                                   <sourceDesc>
                             	        <source/>
                                   </sourceDesc>
                               </fileDesc>
                   		    <workList>
                   			      <work>
                                        <title type="uniform" xml:id="baudi-02-{$IdPartString}-title">
                                            <titlePart type="main" xml:id="baudi-02-{$IdPartString}-titleMain">{$titleMain}</titlePart>
                                            {if($row/cell[5]/string() !='')
                                             then(<titlePart type="number" auth="opus">{$opusNo}</titlePart>)
                                             else()}
                                            <titlePart type="mainSort" xml:id="baudi-02-{$IdPartString}-titleMainSort">{$titleSort}</titlePart>
                                            <titlePart type="subordinate" xml:id="baudi-02-{$IdPartString}-titleSub">{$titleSub}</titlePart>
                                            <titlePart type="perfmedium" xml:id="baudi-02-{$IdPartString}-titleDesc"/>
                                        </title>
                                        <composer xml:id="baudi-02-{$IdPartString}-composer">
                                            {$composer}
                                        </composer>
                                        {if($arranger)
                                        then(<arranger xml:id="baudi-02-{$IdPartString}-arranger">
                                                {$arranger}
                                             </arranger>)
                                        else()}
                                        <lyricist xml:id="baudi-02-{$IdPartString}-lyricist">
                                           {$lyricist}
                                        </lyricist>
                                        {$key}
                                        {$meter}
                                        <tempo>{$tempo}</tempo>
                                        <incip/>
                   				        <perfMedium>
                   					          <perfResList auth="{switch($perfMedium)
                                                                   case 'S,A,T,B' return 'choirMixed'
                                                                   case 'T,T,B,B' return 'choirMen'
                                                                   default return $perfMedium
                                                                  }">
                                                  {for $perfMedium at $i in tokenize($row/cell[29],',')
                                                     let $auth := switch($perfMedium)
                                                                   case 'S' return 'soprano'
                                                                   case 'A' return 'alto'
                                                                   case 'T' return 'tenor'
                                                                   case 'B' return 'bass'
                                                                   case 'Org' return 'organ'
                                                                   case 'Klav' return 'piano'
                                                                   case 'Trp' return 'trumpet'
                                                                   default return $perfMedium
                                                     return
                                                         <perfRes auth="{$auth}" xml:id="{concat('baudi-02-', $IdPartString,'-perfRes-',format-number($i, '0000'))}"/>}
                                                 </perfResList>
                                           {$annotPerf}
                   				        </perfMedium>
                   				        <contents/>
                   			      </work>
                   		    </workList>
                   		    <manifestationList>
                   			      <manifestation class="#pr">
                   				        <identifier type="rism"/>
                   				        <identifier type="baudi-copy">{$row/cell[21]/string()}</identifier>
                   				        <identifier type="blb">{$shelfmark}</identifier>
                   				        <titleStmt>
                   					          <title>
                   					            <titlePart type="main" xml:id="baudi-01-{$IdPartString}-titleMain">{$titleMain}</titlePart>
                   					            <titlePart type="subordinate" xml:id="baudi-01-{$IdPartString}-titleSub">{$titleSub}</titlePart>
                   					          </title>
                   					          <composer xml:id="baudi-01-{$IdPartString}-composer"> 
                                                <persName auth="baudi-04-5e3ed698">{$composer}</persName> 
                                              </composer>
                   					          {if($arranger)
                                               then(<arranger xml:id="baudi-02-{$IdPartString}-arranger">
                                                        {$arranger}
                                                    </arranger>)
                                               else()}
                   					          <lyricist xml:id="baudi-01-{$IdPartString}-lyricist"> 
                                                 <persName auth="baudi-04-35c9a190">{$lyricist}</persName> 
                                              </lyricist>
                   					          <respStmt xml:id="baudi-01-{$IdPartString}-respStmtDed">
                   					               {$dedication}
                   					          </respStmt>
                   				        </titleStmt>
                           				<editionStmt>
                            				   <edition>
                            				   <title>{$titleMain}</title>
                            				   <bibl>
                            				      <identifier>{$plateNum/text()}</identifier>
                            				      <publisher><corpName auth="baudi-05-b8018784">{$publisher}</corpName></publisher>
                            				      <pubPlace><settlement auth="baudi-06-a1ca746a">{$pubPlace}</settlement></pubPlace>
                            				      <date>{$pubDate}</date>
                   				              <dedicatee>{$dedication}</dedicatee>
                            				   </bibl>
                            				   </edition>
                            				   <respStmt>
                            				      <corpName role="printing">{$printer}</corpName>
                            				   </respStmt>
                           				</editionStmt>
                   				        <physDesc>
                   					          <titlePage/>
                   					          <dimensions label="height" unit="mm">{$height}</dimensions>
                   					          <dimensions label="width" unit="mm">{$width}</dimensions>
                   					          <extent label="orientation">portrait</extent>
                   					          <extent label="folium" unit="folium">{$folium}</extent>
                   					          <extent label="pages" unit="page">{$pages}</extent>
                   					          <extent label="pagination">{$pagination}</extent>
                   					          <scoreFormat>choir score</scoreFormat>
                   					          <handList>
                   						            <hand/>
                   					          </handList>
                   					          <!--<physMedium xml:id="baudi-01-{$IdPartString}-physMedium">
                   						          <locus type="paperNotes">
                   							              <rend halign="center" valign="bottom"/>
                   							              <symbol class="suenova-001"/>
                   						            </locus>
                   					          </physMedium>-->
                   					          {$plateNum}
                   				        </physDesc>
                   				        <physLoc>
                   					          <repository> 
                                                    <corpName>Badische Landesbibliothek</corpName> 
                                              </repository>
                   				        </physLoc>
                   				        <creation>{if($row/cell[19]/string() !='')then(concat('Erschienen ',$row/cell[19]/string()))else()}</creation>
                   				        <history></history>
                   				        <langUsage>
                   					          <language label="dt"/>
                   				        </langUsage>
                   				        <contents/>
                   				        <biblList>
                   				            <!-- Erwähnungen der Quelle -->
                   				            <!--<bibl type="letter"/>
                   						          <bibl type="announcement"/>
                   						          <bibl type="notice"/>-->
                   						</biblList>
                   				         <notesStmt>
                                           {if($row/cell[23]/string())
                                           then(<annot type="perf">{$row/cell[23]/string()}</annot>)
                                           else()}
                                           <annot type="internal">{$row/cell[22]/string()}</annot>
                                        </notesStmt>
                   				         <classification>
                                            <head/>
                                            <termList>
                                               <term type="source">print</term>
                                               {if($row/cell[30]/string()='Nachdruck')
                                                then(<term type="source">reprint</term>)
                                                else()}
                                                <term type="workGroup">vocal</term>
                                                <term type="genre">choir</term>
                                            </termList>
                                        </classification>
                                        <relationList>
                                            <relation rel="isEmbodimentOf" corresp="{$relatedWork}"/>
                                        </relationList>
                   			      </manifestation>
                   		    </manifestationList>
                   		    <extMeta xmlns:tei="http://www.tei-c.org/ns/1.0">
                            <tei:person>
                   				        <tei:persName/>
                   			      </tei:person>
                   		    </extMeta>
                   		    <revisionDesc>
                   			      <change n="1" isodate="2020-07-25" label="dried">
                   				        <changeDesc>
                   					          <p>File generated by generateSourcesFromCSV.xql</p>
                   				        </changeDesc>
                   			      </change>
                   		    </revisionDesc>
                   	  </meiHead>
                   	  <music>
                   		    <facsimile/>
                   		    <body>
                   			      <mdiv xml:id="baudi-20-{substring(fn:string(uuid:randomUUID()), 1, 8)}" label="{$titleMain}"/>
                   		    </body>
                   	  </music>
                   </mei>

        where $pos > 1 and $pos != count($rows)
        return
(:            $source:)
            put($source,concat('../../../BauDi/baudiSources/data/music/blb/baudi-01-', $IdPartString, '.xml'))