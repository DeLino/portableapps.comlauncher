${SegmentFile}
!macro _Java_CheckJavaInstall _t _f
	${IfNot} ${Errors}
	${AndIf} ${FileExists} $JavaDirectory\bin\java.exe
	${AndIf} ${FileExists} $JavaDirectory\bin\javaw.exe
		Goto `${_t}`
	${Else}
		Goto `${_f}`
	${EndIf}
!macroend
!macro _Java_FindJava
	${If} $Bit = 64
        ${If} ${FileExists} $PortableAppsDirectory\CommonFiles\Java64
            ClearErrors
            StrCpy $JavaDirectory $PortableAppsDirectory\CommonFiles\Java64
            !insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0
        ${EndIf}
    ${EndIf}
    
    ClearErrors
	StrCpy $JavaDirectory $PortableAppsDirectory\CommonFiles\Java
	!insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0
    
    ClearErrors
    StrCpy $JavaDirectory $PortableAppsDirectory\CommonFiles\JDK
    !insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0

	ClearErrors
	ReadRegStr $0 HKLM "Software\JavaSoft\Java Runtime Environment" CurrentVersion
	ReadRegStr $JavaDirectory HKLM "Software\JavaSoft\Java Runtime Environment\$0" JavaHome
	!insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0
    
	ClearErrors
	ReadRegStr $0 HKLM "Software\JavaSoft\Java Development Kit" CurrentVersion
	ReadRegStr $JavaDirectory HKLM "Software\JavaSoft\Java Development Kit\$0" JavaHome
	!insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0

	ClearErrors
	ReadEnvStr $JavaDirectory JAVA_HOME
	!insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0

	ClearErrors
	SearchPath $JavaDirectory java.exe
	${GetParent} $JavaDirectory $JavaDirectory
	${GetParent} $JavaDirectory $JavaDirectory
	!insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0

	StrCpy $JavaDirectory $PortableAppsDirectory\CommonFiles\Java
	${DebugMsg} "Unable to find Java installation"

_Java_FindJava_Found:
!macroend
${SegmentInit}
	ClearErrors
	ReadINIStr $JavaMode $EXEDIR\App\AppInfo\appinfo.ini Dependencies UsesJava
	${If} $JavaMode == true
		StrCpy $JavaMode yes
	${ElseIf} $JavaMode == false
		StrCpy $JavaMode no
	${EndIf}
	${If} ${Errors}
		${ReadLauncherConfig} $JavaMode Activate Java
		${If} $JavaMode == require
			StrCpy $JavaMode yes
		${ElseIf} $JavaMode == find
			StrCpy $JavaMode optional
		${EndIf}
    ${If} ${Errors}
        ${ReadLauncherConfig} $JavaMode Activate JDK
        ${If} $JavaMode == require
            StrCpy $JavaMode yes
            StrCpy $JDKMode yes
        ${ElseIf} $JavaMode == find
            StrCpy $JavaMode optional
            StrCpy $JDKMode optional
        ${EndIf}
    ${EndIf}
	

	${If}   $JavaMode == yes
	${OrIf} $JavaMode == optional
		!insertmacro _Java_FindJava

		; If Java is required and not found, quit; if it is, check if
		; [Launch]:ProgramExecutable is java.exe or javaw.exe.
		${If} $JavaMode == yes
            ${If} $JDKMode == yes
                ${IfNot} ${FileExists} $JavaDirectory
                    ;=== jdkPortable is missing
                    MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoJDK)`
                    Quit
                ${EndIf}
            ${EndIf}
			${IfNot} ${FileExists} $JavaDirectory
				;=== Java Portable is missing
				MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoJava)`
				Quit
			${EndIf}
			${If}   $ProgramExecutable == java.exe
			${OrIf} $ProgramExecutable == javaw.exe
                ${If} $JDKMode == yes
                ${OrIf} $JDKMode == optional
                    StrCpy $UsingJavaExecutable true
                    ${IfNot} ${FileExists} $JavaDirectory\bin\$ProgramExecutable
                        ;=== The required Java binary (java.exe or javaw.exe) is missing.
                        MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoJDK)`
                        Quit
                ${Else}
                    StrCpy $UsingJavaExecutable true
                    ${IfNot} ${FileExists} $JavaDirectory\bin\$ProgramExecutable
                        ;=== The required Java binary (java.exe or javaw.exe) is missing.
                        MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoJava)`
                        Quit
                    ${EndIf}
                ${EndIf}
			${EndIf}
		${EndIf}

		; Now set %JAVA_HOME% to the path (still may not exist)
		${DebugMsg} "Selected Java path: $JavaDirectory"
		${SetEnvironmentVariablesPath} JAVA_HOME $JavaDirectory
	${ElseIf} $JavaMode != ""
        ${If} $JDKMode != ""
            ${InvalidValueError} [Activate]:JDK $JDKMode
        ${Else}
            ${InvalidValueError} [Activate]:Java $JavaMode
        ${EndIf}
	${EndIf}
!macroend
