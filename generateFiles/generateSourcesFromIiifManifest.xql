xquery version "3.1";
(:
    BauDi, Dennis Ried, 2022
    This script generate an edirom source file (mei) from a iiif manifest
:)
declare default element namespace "http://www.music-encoding.org/ns/mei";
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace functx = "http://www.functx.com";
declare namespace http = "http://expath.org/ns/http-client";
declare namespace util = "http://exist-db.org/xquery/util";
declare namespace fn="http://www.w3.org/2005/xpath-functions";

let $iiifManifestUri := 'https://digital.blb-karlsruhe.de/i3f/v20/3240912/manifest'

let $json := json-doc($iiifManifestUri)
let $sequences := $json?sequences(1)
let $canvasesNos := array:size( $sequences?canvases )
let $surfaces := for $canvasesNo in (1 to $canvasesNos)
                    let $images := $sequences?canvases($canvasesNo)
                    let $target := $images?images(1)?resource?service?*[1]
                    let $width := $images?width
                    let $height := $images?height
                    return
                        <surface xml:id="surface_{util:uuid()}" n="{$canvasesNo}" ulx="0" uly="0" lrx="{$width}" lry="{$height}">
                            <graphic xml:id="graphic_{util:uuid()}" target="{$target}" type="facsimile" width="{$width}" height="{$height}"/>
                            </surface>
let $title := $json?label

let $metadataNos := array:size( $json?metadata )
let $metadata := for $metadataNo in (1 to $metadataNos)
                    let $metadata := $json?metadata($metadataNo)?value
                    return
                        <meta>{$metadata}</meta>

let $source := <mei xmlns="http://www.music-encoding.org/ns/mei"
                        xmlns:xlink="http://www.w3.org/1999/xlink"
                        meiversion="5.0.0-dev"
                        xml:id="{util:uuid()}">
                   	  <meiHead>
                   		    <fileDesc>
                   			      <titleStmt>
                   				        <title>{$title}</title>
                   			      </titleStmt>
                                   <pubStmt/>
                                   <sourceDesc>
                             	        <source>{$iiifManifestUri}</source>
                                   </sourceDesc>
                               </fileDesc>
                   		    <workList>
                   			      <work>
                                        <title/>
                                        
                   			      </work>
                   		    </workList>
                   		    <manifestationList>
                   			      <manifestation>
                   			          {$metadata}
                   			      </manifestation>
                   		    </manifestationList>
                   		    
                   		    <revisionDesc>
                   			      <change n="1" isodate="{current-date()}" label="dried">
                   				        <changeDesc>
                   					          <p>File generated by generateSourcesFromCSV.xql</p>
                   				        </changeDesc>
                   			      </change>
                   		    </revisionDesc>
                   	  </meiHead>
                   	  <music>
                   		    <facsimile>
                   		    {$surfaces}
                   		    </facsimile>
                   		    <body>
                   			      <mdiv/>
                   		    </body>
                   	  </music>
                   </mei>

        return
            $source
