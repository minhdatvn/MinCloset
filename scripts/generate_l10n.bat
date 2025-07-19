@echo off
ECHO Merging .arb files...
call dart run scripts/merge_arb.dart

ECHO Generating localization files...
call flutter gen-l10n

ECHO Done.
pause