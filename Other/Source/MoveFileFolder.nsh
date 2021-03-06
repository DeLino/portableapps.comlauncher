;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; MoveFile and MoveFolder macros
;
; Author:  theblazingangel@aol.com (for the AutoPatcher project - www.autopatcher.com)
; Created: June 2007  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
Description
Allows file/folder renaming/moving with file overwrite control. 
Any existing files will only be overwritten if they will be overwritten by a newer (last modified date) file.

* ADD HEADER @ TOP OF SCRIPT.

[HEADER]
	!include 'FileFunc.nsh'
	!insertmacro Locate

	Var /GLOBAL switch_overwrite
	!include 'MoveFileFolder.nsh'

[SECTION]
	StrCpy $switch_overwrite 0

* $switch_overwrite is used to control overwriting of existing files. 
Setting to 0 (default) means only overwrite files if overwriting with a newer copy (last modified date check). 
Setting to 1 means overwrite reguardless.


Moving/renaming an individual file
==================================
!insertmacro MoveFile "$INSTDIR\[path\]source-file" "$INSTDIR\[path\]destination-file"

This allows you to move and/or rename an individual file. If a file already exists at the destination it will only be overwritten if newer than the existing one (if not then this one will just be deleted)! Please note that wildcards are NOT supported, you can only move/rename a single specific file!

In the following example a file is both moved to a different folder AND renamed:

!insertmacro MoveFile "$INSTDIR\old-folder\old-file-name.txt" "$INSTDIR\new-folder\new-file-name.txt"


Moving/renaming a folder
========================
!insertmacro MoveFolder "$INSTDIR\[path\]source-folder" "$INSTDIR\[path\]destination-folder" "file-mask"

This allows you to move stuff from one folder to another. It also allows you to effectively rename a folder. Note that this command includes all sub-folders!

The 'file-mask' allows you to specify what files to move. Normally you should specify *.*, however if you require, you can have more flexibility over what files are moved! The asterix (*) aka wildcard is a special character that represents one or more unknown characters. If you wanted to move all .exe files you might specify *.exe. If you wanted to move all files that begin with the letter 'a' you might specify a*.*.

Lets look at an example. Renaming a folder:
===========================================
!insertmacro MoveFolder "$INSTDIR\old-folder" "$INSTDIR\new-folder" "*.*"

Another example, this time for some reason you want to move only .exe files:
============================================================================
!insertmacro MoveFolder "$INSTDIR\old-folder" "$INSTDIR\new-folder" "*.exe"

There are a few notes about using MoveFolder:
=============================================
1. There is no way to exclude things (besides the file mask). Anything moved that you didn't want to move you will have to move back! 
2. If all files/sub-folders are moved and the source folder is left empty it will be automatically deleted! 
3. You will lose all empty folders in both the source and destination folders during the move. This is a limitation of the code behind it. You will have to re-create them if you want them!                                  */
 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; MoveFile and MoveFolder macros
;
; Author:  theblazingangel@aol.com (for the AutoPatcher project - www.autopatcher.com)
; Created: June 2007  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
;==================
; MoveFile macro
;==================
 
    !macro MoveFile sourceFile destinationFile
 
	!define MOVEFILE_JUMP ${__LINE__}
 
	; Check source actually exists
 
	    IfFileExists "${sourceFile}" +3 0
	    SetErrors
	    goto done_${MOVEFILE_JUMP}
 
	; Add message to details-view/install-log
 
;	    DetailPrint "Moving/renaming file: ${sourceFile} to ${destinationFile}"
 
	; If destination does not already exists simply move file
 
	    IfFileExists "${destinationFile}" +3 0
	    rename "${sourceFile}" "${destinationFile}"
	    goto done_${MOVEFILE_JUMP}
 
	; If overwriting without 'ifnewer' check
 
	    StrCmp $switch_overwrite 1 0 +5
		delete "${destinationFile}"
		rename "${sourceFile}" "${destinationFile}"
		delete "${sourceFile}"
		goto done_${MOVEFILE_JUMP}
 
	; If destination already exists
 
	    Push $R0
	    Push $R1
	    Push $R2
	    push $R3
 
	    GetFileTime "${sourceFile}" $R0 $R1
	    GetFileTime "${destinationFile}" $R2 $R3
 
	    IntCmp $R0 $R2 0 older_${MOVEFILE_JUMP} newer_${MOVEFILE_JUMP}
	    IntCmp $R1 $R3 older_${MOVEFILE_JUMP} older_${MOVEFILE_JUMP} newer_${MOVEFILE_JUMP}
 
	    older_${MOVEFILE_JUMP}:
		    delete "${sourceFile}"
		    goto time_check_done_${MOVEFILE_JUMP}
 
	    newer_${MOVEFILE_JUMP}:
		    delete "${destinationFile}"
		    rename "${sourceFile}" "${destinationFile}"
		    delete "${sourceFile}" ;incase above failed!
 
	    time_check_done_${MOVEFILE_JUMP}:
 
	    Pop $R3
	    Pop $R2
	    Pop $R1
	    Pop $R0
 
	done_${MOVEFILE_JUMP}:
 
	!undef MOVEFILE_JUMP
 
    !macroend
 
;==================
; MoveFolder macro
;==================
 
    !macro MoveFolder source destination mask
 
	!define MOVEFOLDER_JUMP ${__LINE__}
 
	Push $R0
	Push $R1
 
	; Move path parameters into registers so they can be altered if necessary
 
	    StrCpy $R0 "${source}"
	    StrCpy $R1 "${destination}"
 
	; Sort out paths - remove final backslash if supplied
 
;	    Push $0
 
	    ; Source
;	    StrCpy $0 "$R0" 1 -1
;	    StrCmp $0 '\' 0 +2
;	    StrCpy $R0 "$R0" -1
 
	    ; Destination
;	    StrCpy $0 "$R1" 1 -1
;	    StrCmp $0 '\' 0 +2
;	    StrCpy $R1 "$R1" -1
 
;	    Pop $0
 
	; Create destination dir
 
	    CreateDirectory "$R1"
 
	; Add message to details-view/install-log
 
;	    DetailPrint "Moving files: $R0\${mask} to $R1"
 
	; Push registers used by ${Locate} onto stack
 
	    Push $R6
	    Push $R7
	    Push $R8
	    Push $R9
 
	; Duplicate dir structure (to preserve empty folders and such)
 
	    ${Locate} "$R0" "/L=D" ".MoveFolder_Locate_createDir"
 
	; Locate files and move (via callback function)
 
	    ${Locate} "$R0" "/L=F /M=${mask} /S= /G=1" ".MoveFolder_Locate_moveFile"
 
	; Delete subfolders left over after move
 
	    Push $R2
	    deldir_loop_${MOVEFOLDER_JUMP}:
	    StrCpy $R2 0
	    ${Locate} "$R0" "/L=DE" ".MoveFolder_Locate_deleteDir"
	    StrCmp $R2 0 0 deldir_loop_${MOVEFOLDER_JUMP}
	    Pop $R2
 
	; Delete empty subfolders moved - say the user just wanted to move *.apm files, they now also have a load of empty dir's from dir structure duplication!
 
	    Push $R2
	    delnewdir_loop_${MOVEFOLDER_JUMP}:
	    StrCpy $R2 0
	    ${Locate} "$R1" "/L=DE" ".MoveFolder_Locate_deleteDir"
	    StrCmp $R2 0 0 delnewdir_loop_${MOVEFOLDER_JUMP}
	    Pop $R2
 
	; Pop registers used by ${Locate} off the stack again
 
	    Pop $R9
	    Pop $R8
	    Pop $R7
	    Pop $R6
 
	; Delete source folder if empty
 
	    rmdir /r "$R0"
 
	Pop $R1
	Pop $R0
 
	!undef MOVEFOLDER_JUMP
 
    !macroend
 
;==================
; MoveFolder macro's ${Locate} callback functions
;==================
 
Function .MoveFolder_Locate_createDir
	StrCmp $R6 "" 0 +6
	Push $R2
	StrLen $R2 "$R0"
	StrCpy $R2 $R9 '' $R2
	CreateDirectory "$R1$R2"
	Pop $R2
	Push $R1
FunctionEnd

Function .MoveFolder_Locate_moveFile
	Push $R2
	StrLen $R2 "$R0"
	StrCpy $R2 $R9 '' $R2
	StrCpy $R2 "$R1$R2"
	IfFileExists "$R2" +3 0
	rename "$R9" "$R2"
	goto done
	StrCmp $switch_overwrite 1 0 +5
	delete "$R2"
	rename "$R9" "$R2"
	delete "$R9"
	goto done
	Push $0
	Push $1
	Push $2
	push $3
	GetFileTime "$R9" $0 $1
	GetFileTime "$R2" $2 $3
	IntCmp $0 $2 0 older newer
	IntCmp $1 $3 older older newer
	older:
	delete "$R9"
	goto time_check_done
	newer:
	delete "$R2"
	rename "$R9" "$R2"
	delete "$R9"
	time_check_done:
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	done:
	Pop $R2
	Push $R1
FunctionEnd

Function .MoveFolder_Locate_deleteDir
	StrCmp $R6 "" 0 +3
	RMDir $R9
	IntOp $R2 $R2 + 1
	Push $R1
FunctionEnd