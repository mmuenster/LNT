PossibleDrives=ZYXWVUTSRQPONMLKJIHGFE

version:=URLDownloadToVar("https://dazzling-torch-3393.firebaseio.com/AveroQueue/Settings/cassReceiveVersion.json")

StringReplace, version, version, ",,All

Loop, Parse, PossibleDrives
	IfExist, %A_LoopField%:\LNT\cassLink\cassReceive-%version%.ahk
	{
		Run, %A_LoopField%:\LNT\lib\Autohotkey\Autohotkey.exe %A_LoopField%:\LNT\cassLink\cassReceive-%version%.ahk
		break
	}

ExitApp
	
URLDownloadToVar(url){
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	return hObject.ResponseText
}