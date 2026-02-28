I want us to embark on a project to improve the export-to-LaTeX functionality of the scripta V3 app.  The idea  is the following. From time to time I will put documents in the folder

  tests/toLaTeXExportTestDocs

There is one doc there now, welcome.scripta.  A document like this can be exported
to LaTeX by sending a Types.PrintToPDF message from the V3 app located at

  /Users/carlson/dev/elm-work/scripta/scripta-app-v3

Info about how this is done is detiled in section "# NOTES" below.  There very
last stage of the process involves interaction with the pdf server app.  The
code for it is a

   /Users/carlson/dev/elm-work/scripta/pdfServer2

Our first task is develop the means to take a file with Scripta Markup source code,
e.g. that in welcome.scripta, send it to the server, accept the error log if any
and write it to tests/toLaTeXExportTestDocs as FILENAME-errors.json.  (I believe
that the error log is returned as JSON).  If there is no error log, write some
short json file indicating that there are no errors. This will require making and http request
to the server.

Code that does this should be written to tests/toLaTeXExport/



Once we have this working, we will proceed with further planning.

# NOTES

⏺ The button sends the Types.PrintToPDF message. Let me trace what that message does.

⏺ Searched for 2 patterns, read 1 file (ctrl+o to expand)

⏺ Here's the chain:

  The printer icon ("Get PDF") sends the Types.PrintToPDF message, handled at src/Frontend.elm:2443.

  It does the following:

  1. Takes the current editor content (model.sourceText, not the saved document) so the PDF reflects the latest unsaved edits
  2. Builds publication data via Frontend.Export.publicationData
  3. Parses the source text into a syntax tree using ScriptaV2.Compiler.parseFromString
  4. Creates export settings (with isStandaloneDocument = True)
  5. Prepares export data via Frontend.PDF.prepareExportData (converting the document to LaTeX)
  6. Sends the LaTeX to an external PDF service via Frontend.PDF.requestPDF
  7. Sets printingState to PrintProcessing (showing "Please wait..." on the button)

  When the PDF is ready, the button transitions to PrintReady and shows a link to download the PDF from Config.pdfServUrl.
