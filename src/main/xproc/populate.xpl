<p:declare-step version="3.0"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cnf="https://doi.org/10.5281/zenodo.5679629#"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <p:input  port="source"/>
  <p:output port="result"/>

  <p:declare-step type="cnf:populate-testcase">
    <p:documentation>Populate testcase file to filesystem</p:documentation>

    <p:input  port="source"/>
    <p:output port="result"/>

    <p:option name="basedir" as="xs:anyURI" required="true"/>
    <p:option name="queryBinding" as="xs:string" required="true"/>

    <p:variable name="subdir" as="xs:anyURI" select="tokenize($basedir, '/')[last() - 1]"/>

    <!-- Serialize schema and replace content with content reference -->
    <p:variable name="no-explicit-schema" as="xs:boolean"
                select="not(cnf:testcase/cnf:schemas/cnf:schema[sch:schema/@queryBinding = $queryBinding])"/>
    <p:viewport match="cnf:schema" name="serialize-schema">
      <p:if test="(not(cnf:schema/sch:schema/@queryBinding) and $no-explicit-schema) or (cnf:schema/sch:schema/@queryBinding = $queryBinding)">
        <p:add-attribute match="cnf:schema" attribute-name="uuid" attribute-value="#uuid#"/>
        <p:uuid match="cnf:schema/@uuid"/>
        <p:add-attribute match="cnf:schema/sch:schema" attribute-name="queryBinding" attribute-value="{$queryBinding}"/>
        <p:variable name="filename" as="xs:string" select="concat(cnf:schema/@uuid, '.sch')"/>
        <p:variable name="href" as="xs:anyURI" select="resolve-uri($filename, $basedir)"/>
        <p:add-attribute attribute-name="href" attribute-value="{$subdir}/{$filename}"/>
        <p:identity name="before-store"/>
        <p:store href="{$href}">
          <p:with-input select="cnf:schema/sch:schema"/>
        </p:store>
        <p:delete match="cnf:schema/node()">
          <p:with-input pipe="result@before-store"/>
        </p:delete>
        <p:delete match="cnf:schema/@uuid"/>
      </p:if>
    </p:viewport>

    <p:delete match="cnf:schemas/cnf:schema[not(@href)]"/>

    <!-- Serialize documents and replace content with content reference -->
    <p:viewport match="cnf:documents/cnf:document" name="serialize-documents">
      <p:variable name="filename" as="xs:string" select="cnf:document/@filename"/>
      <p:variable name="href" as="xs:anyURI" select="resolve-uri($filename, $basedir)"/>
      <p:store href="{$href}">
        <p:with-input select="cnf:document/*[1]"/>
      </p:store>
      <p:add-attribute attribute-name="href" attribute-value="{$subdir}/{$filename}">
        <p:with-input pipe="current@serialize-documents"/>
      </p:add-attribute>
      <p:delete match="cnf:document/@filename"/>
      <p:delete match="cnf:document/node()"/>
    </p:viewport>

    <p:identity/>

  </p:declare-step>

  <cnf:populate-testcase basedir="{p:urify('/tmp/fooo/')}" queryBinding="xslt3"/>

</p:declare-step>
