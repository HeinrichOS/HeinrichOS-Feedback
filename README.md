# HeinrichOS Players Edition V1.6 - Nexus review source

This source snapshot was prepared for Nexus Mods manual review, ticket #268314, Mod ID 3752.

It corresponds to the Nexus-clean candidate submitted on 2026-09-30.
Submitted ZIP SHA256: 095AC4EA8D52390CEAB4A10980CF323C7473488D22B66FF5BFB0BA20FF36D1F6
Submitted HeinrichOS.exe SHA256: 877F63E5332EF12D25DEAFF2D3A7F80AD3818889B3C3879BE2E99F6F122851FC

Included here:
- complete C# launcher source
- complete static HTML / JavaScript / CSS application source and data
- shipped local update-engine PowerShell source
- startup scripts, manifests and public documentation
- exact XML source extracted from the three bundled HeinrichOS Wardrobe PAK containers
- launcher artwork required to compile and review the launcher

Not included as source:
- the generated HeinrichOS.exe
- the three generated PAK containers
- large PNG / SVG / JPG application artwork assets

Those excluded files are non-executable assets or generated containers. Their release hashes remain listed in the shipped DATEIMANIFEST_SHA256.txt.

The protected f116_data.js file is copied byte-for-byte from the reviewed package and was not edited.
f116_data.js SHA256: 8F5659F10DB5811FB0637DD7CCCE986905765415E0AF6AD0D0FA557919060B89

See BUILD.md and SECURITY_REVIEW.md for build and behavior details.


## GitHub transport note
The two largest JavaScript files are stored as raw byte parts under large-source-parts because the connected GitHub upload path has a per-request size limit.
Run REASSEMBLE_LARGE_SOURCE.cmd to restore app.js and f116_data.js byte-for-byte before a full source-tree comparison.
See LARGE_SOURCE_PARTS.md.
