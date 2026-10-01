# Security review notes

This document describes the behavior of the Nexus-clean V1.6 source.

Launcher:
- no powershell.exe process is launched
- no ExecutionPolicy Bypass string or call exists
- the Update button only displays that the public update channel is disabled
- RunUpdateEngine returns code 10 and does not start another process
- Process.Start is used only for local files and the explicit Feedback browser action
- Feedback opens https://github.com/HeinrichOS/HeinrichOS-Feedback/issues/new/choose
- no hidden background updater is started

Static application:
- no fetch(), XMLHttpRequest, WebSocket or sendBeacon calls were found
- external reference links may be opened only through explicit user actions
- the application itself runs from local HTML / JS / CSS files

Update engine:
- updater.ps1 is included because it exists in the release package
- the public V1.6 launcher does not invoke it
- it contains no network download routines
- it operates only on an explicitly supplied local TargetPath and local PackageRoot
- it validates SHA256 values, stages writes, keeps backups and performs rollback checks

Local review before publication found no embedded credentials, private key material, private Windows user paths, or project-local D:\ paths in the source snapshot.
