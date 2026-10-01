# Large source files

For transport through the connected GitHub API, the two largest JavaScript files are stored as raw byte parts:

- app.js: 13 parts
- f116_data.js: 12 parts

Run REASSEMBLE_LARGE_SOURCE.cmd from the repository root on Windows.
It concatenates the parts byte-for-byte into their original paths under release-source.

The canonical source hashes are recorded in SOURCE_MANIFEST_SHA256.txt.
The protected f116_data.js must reconstruct to:
8F5659F10DB5811FB0637DD7CCCE986905765415E0AF6AD0D0FA557919060B89

No source content was edited during splitting; this is transport chunking only.
