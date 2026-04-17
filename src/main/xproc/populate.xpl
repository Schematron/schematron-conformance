<p:declare-step version="3.0"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cnf="https://doi.org/10.5281/zenodo.5679629#"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <p:input  port="source"/>

  <p:option name="basedir" as="xs:anyURI" required="true"/>
  <p:option name="queryBinding" as="xs:string" required="true"/>

  <p:declare-step type="cnf:perform-include">
    <p:documentation>Recursively include testsuite specifications</p:documentation>

    <p:input  port="source"/>
    <p:output port="result"/>

    <p:viewport match="cnf:testsuite/cnf:include">
      <p:variable name="href" as="xs:anyURI" select="resolve-uri(cnf:include/@href, base-uri(cnf:include))"/>
      <p:load href="{$href}"/>
      <p:delete match="cnf:label"/>
      <p:unwrap match="cnf:testsuite"/>
      <p:viewport match="cnf:testcase">
        <p:add-attribute attribute-name="href" attribute-value="{resolve-uri(cnf:testcase/@href, base-uri(cnf:testcase))}"/>
      </p:viewport>
      <cnf:perform-include/>
    </p:viewport>

  </p:declare-step>

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

  </p:declare-step>

  <p:declare-step type="cnf:populate-testsuite">
    <p:documentation>Populate testsuite to filesystem</p:documentation>

    <p:input  port="source"/>
    <p:output port="result"/>

    <p:option name="basedir" as="xs:anyURI" required="true"/>
    <p:option name="queryBinding" as="xs:string" required="true"/>

    <cnf:perform-include/>

    <p:viewport match="cnf:testcase" name="populate-testcases">
      <p:add-attribute match="cnf:testcase" attribute-name="uuid" attribute-value="#uuid#"/>
      <p:uuid match="cnf:testcase/@uuid"/>
      <p:variable name="name" as="xs:string" select="tokenize(cnf:testcase/@href, '/')[last()]"/>
      <p:variable name="category" as="xs:string" select="tokenize(cnf:testcase/@href, '/')[last() - 1]"/>
      <p:variable name="subdir" as="xs:string" select="cnf:testcase/@uuid"/>
      <p:identity name="before-load"/>
      <p:load href="{resolve-uri(cnf:testcase/@href, base-uri(cnf:testcase))}"/>
      <cnf:populate-testcase basedir="{$basedir}/{$category}/{$subdir}/" queryBinding="{$queryBinding}"/>
      <p:store href="{$basedir}/{$category}/{$name}"/>
      <p:add-attribute attribute-name="href" attribute-value="{$category}/{$name}">
        <p:with-input pipe="result@before-load"/>
      </p:add-attribute>
      <p:delete match="cnf:testcase/@uuid"/>
    </p:viewport>

    <p:delete match="text()[normalize-space() eq '']"/>
    <p:store href="{resolve-uri('testsuite.xml', $basedir)}"/>

  </p:declare-step>

  <cnf:populate-testsuite basedir="{if (ends-with($basedir, '/')) then p:urify($basedir) else p:urify(concat($basedir, '/'))}" queryBinding="{$queryBinding}"/>

</p:declare-step>
