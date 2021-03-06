Var LastDirectory
${SegmentFile}
${SegmentInit}
	${GetRoot} $EXEDIR $0
	StrLen $0 $0
	StrCpy $1 $EXEDIR "" $0
	${If} $1 == ""
		StrCpy $1 "\"
	${EndIf}
	${ReadSettings} $LastDirectory LastDirectory
	${If} $LastDirectory == ""
		StrCpy $LastDirectory $1
	${EndIf}
	${If} $LastDirectory != $1
		ClearErrors
		${ReadLauncherConfig} $0 Launch DirectoryMoveOK
		${If} $0 == no
			MessageBox MB_ICONSTOP "$(LauncherDirectoryMoveNotAllowed)"
			Call Unload
			Quit
		${ElseIf} $0 == warn
		${OrIf} ${Errors}
			MessageBox MB_YESNO|MB_ICONSTOP "$(LauncherDirectoryMoveWarn)" IDYES +3 IDNO 0
			Call Unload
			Quit
		${EndIf}
	${EndIf}
	${SetEnvironmentVariablesPath} PAL:PackagePartialDir $1
	${SetEnvironmentVariablesPath} PAL:LastPackagePartialDir $LastDirectory
!macroend
${SegmentPrePrimary}
	ReadEnvStr $0 PAL:PackagePartialDir
	${WriteSettings} $0 LastDirectory
!macroend
