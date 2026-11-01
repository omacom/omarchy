# Formal checks

The plugin scanner uses three NUL-terminated fields per record: origin, source directory and manifest. The origin and directory come from the scanner's traversal. Manifest contents must never supply another record or change that origin.

[plugin-scan.muro](plugin-scan.muro) models framing and reading a field. A text token represents any non-NUL code unit; a boundary token represents NUL. Bash variables and filesystem names cannot contain NUL. The model starts at that transport boundary, after Bash has read the file into a variable.

The evidence proves that reading a framed field returns exactly its contents and the entire following stream, for every field and suffix. Applied to each of the three fields, this keeps manifest text from becoming the origin or source of another record. Newlines, old record markers and arbitrary field lengths are covered by the quantified theorem.

Use Muro 0.20.3, which includes the imported standard library:

~~~bash
mise install github:murolang/muro@0.20.3
mise exec github:murolang/muro@0.20.3 -- muro check test/formal/plugin-scan.muro
mise exec github:murolang/muro@0.20.3 -- muro mutate test/formal/plugin-scan.muro --only frame --only read-field --max-survivors 0
~~~

This installs a separate tool version without changing the user's global selection. The formal-check workflow uses the same release and verifies the executable against a pinned SHA-256.

The proof covers the Muro framing model. The implementation connection is checked by the existing plugin-manifest-scan test, which runs the actual Bash scanner and registry parser against malformed local manifests and source names containing newlines. The registry fixture separately checks NUL preservation through Quickshell's native Process and StdioCollector. Those tests remain necessary: the proof does not verify Bash, Qt, JSON parsing or the implementation of Muro.
