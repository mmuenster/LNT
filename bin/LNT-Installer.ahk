PossibleDrives=ZYXWVUTSRQPONMLKJIHGFE

StringReplace, newPath, A_MyDocuments, Documents, Desktop, All

Loop, Parse, PossibleDrives
	IfExist, %A_LoopField%:\LNT\bin\LNT-Launcher.exe
	{
		FileCopy, %A_LoopField%:\LNT\bin\LNT-Launcher.exe, %newPath%\LNT-Launcher.exe
		break
	}

ExitApp
	