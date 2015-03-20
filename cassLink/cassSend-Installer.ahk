PossibleDrives=ZYXWVUTSRQPONMLKJIHGFE

StringReplace, newPath, A_MyDocuments, Documents, Desktop, All

Loop, Parse, PossibleDrives
	IfExist, %A_LoopField%:\LNT\cassLink\cassSend-Launcher.exe
	{
		msgbox, "Got here"
		FileCopy, %A_LoopField%:\LNT\cassLink\cassSend-Launcher.exe, %newPath%\cassSend-Launcher.exe
		
		break
	}

ExitApp
	