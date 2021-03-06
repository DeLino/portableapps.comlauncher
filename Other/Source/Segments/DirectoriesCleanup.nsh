${SegmentFile}
${SegmentPostPrimary}
	!ifmacrodef DirCleanup
		!insertmacro DirCleanup
	!endif
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $1 DirectoriesCleanupIfEmpty $R0
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${ParseLocations} $1
		${ForEachDirectory} $2 $3 $1
			RMDir $2
		${NextDirectory}
		IntOp $R0 $R0 + 1
	${Loop}
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $1 DirectoriesCleanupForce $R0
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${ParseLocations} $1
		${ForEachDirectory} $2 $3 $1
			RMDir /r $2
		${NextDirectory}
		IntOp $R0 $R0 + 1
	${Loop}
!macroend
${SegmentUnload}
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $1 DirectoriesCleanupIfEmpty $R0
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${ParseLocations} $1
		${ForEachDirectory} $2 $3 $1
			RMDir $2
		${NextDirectory}
		IntOp $R0 $R0 + 1
	${Loop}
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $1 DirectoriesCleanupForce $R0
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${ParseLocations} $1
		${ForEachDirectory} $2 $3 $1
			RMDir /r $2
		${NextDirectory}
		IntOp $R0 $R0 + 1
	${Loop}
!macroend
