<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
            xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
            xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Sep 19, 2017</xd:p>
      <xd:p><xd:b>Author:</xd:b> Benjamin W. Bohl</xd:p>
      <xd:p>For use in Edirom Tools workshop at the the Edirom-Summer-School 2017</xd:p>
    </xd:desc>
  </xd:doc>
  <sch:ns uri="http://www.music-encoding.org/ns/mei" prefix="mei"/>
  <sch:ns uri="http://www.tei-c.org/ns/1.0" prefix="tei"/>
  
  <sch:pattern>
    <sch:rule context="/*">
      <!-- HeaderView -->
      <sch:report test="//mei:meiHead">
        HeaderView for MEI
      </sch:report>
      <sch:report test="//tei:teiHeader">
        HeaderView for TEI
      </sch:report>
      
      <!-- SourceDescriptionView -->
      <sch:report test="//mei:annot[@type='descLink']">
        SourceDescriptionView for MEI
      </sch:report>
      
      <!-- SourceView -->
      <sch:report test="//mei:facsimile//mei:graphic[@type='facsimile']">
        SourceView for MEI
      </sch:report>
      
      <!-- AudioView -->
      <sch:report test="//mei:recording">
        AudioView for MEI
      </sch:report>
      
      <!-- RenderingView -->
      <sch:report test="//mei:body//mei:measure and //mei:body//mei:note">
        RenderingView for MEI with Verovio
      </sch:report>
      
      <!-- TextView -->
      <sch:report test="//tei:body[matches(.//text(), '[^\s]+')]">
        TextView for TEI
      </sch:report>
      
      <!-- SourceView -->
      <sch:report test="//tei:facsimile//tei:graphic">
        SourceView for TEI
      </sch:report>
      
      <!-- TextFacsimileSplitView -->
      <sch:report test="//tei:facsimile//tei:graphic and //tei:pb[@facs]">
        TextFacsimileSplitView for TEI
      </sch:report>
      
      <!-- AnnotationView -->
      <sch:report test="//mei:annot[@type='editorialComment']">
        AnnotationView for MEI
      </sch:report>
      
      <!-- TODO iFrameView -->
      <!-- TODO XmlView -->
      
      <!-- SourceDescriptionView -->
      <sch:report test="//mei:annot[@type='descLink']">
        SourceDescriptionView for MEI
      </sch:report>
    </sch:rule>
    
    
  </sch:pattern>
  
</sch:schema>