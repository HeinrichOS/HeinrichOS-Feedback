# Build instructions

## Launcher
The public launcher is a single C# WinForms source file and requires no Visual Studio project.

On Windows, run BUILD_LAUNCHER.cmd from the repository root.
It uses the .NET Framework 4.x C# compiler already present on standard Windows installations.

Exact compiler flags used for the submitted Nexus-clean launcher:
csc.exe /nologo /target:winexe /optimize+ /platform:anycpu /win32icon:heinrichos.ico /reference:System.dll /reference:System.Drawing.dll /reference:System.Windows.Forms.dll /out:HeinrichOS.exe HeinrichOSLauncher.cs

The script first tries:
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
and then the 32-bit Framework path if needed.

Launcher source SHA256:
C1E16D67BA15C2DAEA2D62305DC9E4E32520334024E3F6862348524D646F4B61

## Static application
The HTML / JavaScript / CSS application has no compile, bundling or minification step.
The files under release-source\HOS_SYSTEM\APP are copied as-is into the release package.

## Wardrobe PAKs
The three shipped .pak files are ZIP-compatible containers.
Their exact XML contents were extracted into SOURCE_EXTRACTED for review.
Repacking may produce byte-different archives because ZIP metadata can differ.

## Rebuild hash note
The legacy .NET Framework compiler is not bit-for-bit deterministic in this build mode.
Two rebuilds from the same source produced different SHA256 values while retaining the same code and version metadata.
The authoritative submitted binary hash is therefore the value recorded in RELEASE_HASHES.md.
