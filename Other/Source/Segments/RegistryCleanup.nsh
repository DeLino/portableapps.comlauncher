${SegmentFile}
${SegmentPostPrimary}
	!ifmacrodef RegCleanup
		!insertmacro RegCleanup
	!endif
	${If} $Registry == true
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $R1 RegistryCleanupIfEmpty $R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ValidateRegistryKey} $R1
			${ParseLocations} $R1
			${registry::DeleteKeyEmpty} $R1 $R2
			IntOp $R0 $R0 + 1
		${Loop}
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $R1 RegistryCleanupForce $R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ValidateRegistryKey} $R1
			${ParseLocations} $R1
			${registry::DeleteKey} $R1 $R2
			IntOp $R0 $R0 + 1
		${Loop}
	${EndIf}
!macroend
