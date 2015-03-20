PossibleDrives=ZYXWVUTSRQPONMLKJIHGFE

StringReplace, newPath, A_MyDocuments, Documents, Desktop, All

Loop, Parse, PossibleDrives
	IfExist, %A_LoopField%:\LNT\cassLink\cassReceive-Launcher.exe
	{
		FileCopy, %A_LoopField%:\LNT\cassLink\cassReceive-Launcher.exe, %newPath%\cassReceive-Launcher.exe
		
		break
	}

ExitApp
	