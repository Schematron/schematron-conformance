Schematron conformance tests
==

A Schematron conformance test is described in a self-contained document that defines the one or more input documents, a
schema, and the expected result of validating the documents with the schema.

Directory structure
===

The directory [src/main/resources/testcases](src/main/resources/testcases) contains all test cases. The test case files
are grouped into subdirectories following the classification of [MAUS 2021]:

* rule-based validation
* schema composition
* reporting
* pattern templating
* instance document selection

The directory [src/main/resources/testsuites](src/main/resources/testsuites) contains all test suite files. They are
also grouped into subdirectories like above.


Bibliography
===

[MAUS 2021] : Maus, David. 2021. „What’s in a Schematron?“ In Markup UK 2021
Proceedings. Online. https://markupuk.org/webhelp/index.html#ar02.html.
