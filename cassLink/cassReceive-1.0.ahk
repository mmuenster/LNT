;cassReceive.ahk

#SingleInstance, Force

windowTitle := "HistoPAL-Quick Print"

urlQueue = https://dazzling-torch-3393.firebaseio.com/CassettePrinting.json?limitToFirst=1&orderBy="$key"

GUI, Add, Button, vButtonEnable , Enable
Gui, Add, Button, vButtonDisable, Disable

Gui, Font, S30
Gui, Add, Text, vEnabledLabel, Disabled
Gui, Show, W300 H300
return


ButtonEnable:
SetTimer, WorkLoop, 11000
GuiControl, , EnabledLabel, Enabled
return

ButtonDisable:
SetTimer, WorkLoop, Off
GuiControl, , EnabledLabel, Disabled
return

WorkLoop:
if (A_TimeIdlePhysical > 10000 and enteringCase<>true)
{
	IfWinNotExist, Leica(IP-C)
		PrintNextCassettes(urlQueue)
}

return

GuiClose:
ExitApp
return


!^t::
{
	Loop,
		{
		SplashTextOn, 100, 100, IdleTime, %A_TimeIdlePhysical%
		Sleep, 100
	}
	
return
}

F12::PrintNextCassettes(urlQueue)

PrintNextCassettes(urlQueue)
{
global

j := URLDownloadToVar(urlQueue)

if (j="{}")
	Return

enteringCase := true

t := JsonToObject(j)

For k,v in t
	key:=k	

accessionNumber := t[key].accessionNumber
blockLetter := t[key].data.blockLetter
blockLetterQuantity := t[key].data.blockLetterQuantity
prefixOption := GetPrefixIndex(GetShortPrefix(t[key].prefix))
specimenNumber := t[key].data.specimenNumber
specimenNumberQuantity := t[key].data.specimenNumberQuantity
fullName := t[key].fullName
fullName := SubStr(fullName, 1, 10)
stringUpper, fullName, fullName
magazineOption := GetMagazine(t[key].cassetteMagazine)

BlockInput, On	
	WinActivate, %windowTitle%

	ControlSetText, TTntEdit.UnicodeClass1, , %windowTitle%
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass1, %accessionNumber%, %windowTitle% 
	TypingDelay()
	ControlClick, TTntEdit.UnicodeClass1, %windowTitle%
	TypingDelay()
	ControlSetText, TTNtEdit.UnicodeClass7, , %windowTitle%
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass7, %blockLetter%, %windowTitle%
	TypingDelay()
	ControlClick, TTntEdit.UnicodeClass7, %windowTitle%
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass4, , %windowTitle%
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass4, %blockLetterQuantity%, %windowTitle%
	TypingDelay()
	ControlClick, TTntEdit.UnicodeClass4, %windowTitle%
	TypingDelay()
	ControlClick, TTntComboBox.UnicodeClass1, %windowTitle%
	TypingDelay()
	Control, Choose, %prefixOption%, TTntComboBox.UnicodeClass1, %windowTitle%	
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass6, , %windowTitle%
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass6, %specimenNumber%, %windowTitle%
	TypingDelay()
	ControlClick, TTntEdit.UnicodeClass6, %windowTitle%
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass5, , %windowTitle%
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass5, %specimenNumberQuantity%, %windowTitle%
	TypingDelay()
	ControlClick, TTntEdit.UnicodeClass5, %windowTitle%
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass8, , %windowTitle%
	TypingDelay()
	ControlSetText, TTntEdit.UnicodeClass8, %fullName%, %windowTitle%
	TypingDelay()
	ControlClick, TTntEdit.UnicodeClass8, %windowTitle%
	TypingDelay()
	ControlClick, TTntComboBox.UnicodeClass2
	TypingDelay()
	Control, Choose, %magazineOption%, TTntComboBox.UnicodeClass2, %windowTitle%
	TypingDelay()
	ControlClick, TLbButton1, %windowTitle%
	
	urlToDelete=https://dazzling-torch-3393.firebaseio.com/CassettePrinting/%key%.json
	URLDelete(urlToDelete)
BlockInput, Off

enteringCase := false

Return
}

TypingDelay()
{
	Sleep, 50
	return
}

GetShortPrefix(prefix)
{
	stringLen, prefixLength, prefix
	if (prefixLength=5)
		shortPrefix:=Substr(prefix,1,3)
	else
		shortPrefix:=Substr(prefix,1,2)

	return shortPrefix
}

URLDownloadToVar(url){
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	return hObject.ResponseText
}

UrlDelete(URL){
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("DELETE",url)
	hObject.Send()
	return hObject.ResponseText
	return
}

UrlPost(URL, data) {
   WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   WebRequest.Open("POST", URL, false)
   WebRequest.Send(data)
   Return WebRequest.ResponseText
}

UrlPatch(URL, data) {
   WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   WebRequest.Open("PATCH", URL, false)
   WebRequest.Send(data)
   Return WebRequest.ResponseText
}

GetMagazine(mag)
{
	if (mag="Magazine 1")
		j := 1
	else if (mag="Magazine 2")
		j := 2
	else if (mag="Magazine 3")
		j := 3
	else if (mag="Magazine 4")
		j := 4
	else if (mag="Magazine 5")
		j := 5
	else if (mag="Magazine 6")
		j := 6
	
	return j
}

GetPrefixIndex(prefix)
{
if (prefix="BS")
	j := 2
else if (prefix="GIS")
	j := 3
else if (prefix="GYS")
	j := 4
else if (prefix="SP")
	j := 5
else if (prefix="TSP")
	j := 6
else if (prefix="TUC")
	j := 7
else if (prefix="TUS")
	j :=8
else if (prefix="UC")
	j := 9
else if (prefix="US")
	j := 10

return j
}



ScrollLock::Suspend	
^!v::ListVars   ;List the variables currently in memory.
^!l::ListLines  ;List the most recently executed lines of code.
Pause::Pause
^!r::
{
PossibleDrives=ZYXWVUTSRQPONMLKJIHGFE

version:=URLDownloadToVar("https://dazzling-torch-3393.firebaseio.com/AveroQueue/Settings/cassReceiveVersion.json")

StringReplace, version, version, ",,All

Loop, Parse, PossibleDrives
	IfExist, %A_LoopField%:\LNT\cassLink\cassReceive-%version%.ahk
	{
		Run, %A_LoopField%:\LNT\lib\Autohotkey\Autohotkey.exe %A_LoopField%:\LNT\cassLink\cassReceive-%version%.ahk
		break
	}
}


JsonToObject( str ) {

	quot := """" ; firmcoded specifically for readability. Hardcode for (minor) performance gain
	ws := "`t`n`r " Chr(160) ; whitespace plus NBSP. This gets trimmed from the markup
	obj := {} ; dummy object
	objs := [] ; stack
	keys := [] ; stack
	isarrays := [] ; stack
	literals := [] ; queue
	y := nest := 0

; First pass swaps out literal strings so we can parse the markup easily
	StringGetPos, z, str, %quot% ; initial seek
	while !ErrorLevel
	{
		; Look for the non-literal quote that ends this string. Encode literal backslashes as '\u005C' because the
		; '\u..' entities are decoded last and that prevents literal backslashes from borking normal characters
		StringGetPos, x, str, %quot%,, % z + 1
		while !ErrorLevel
		{
			StringMid, key, str, z + 2, x - z - 1
			StringReplace, key, key, \\, \u005C, A
			If SubStr( key, 0 ) != "\"
				Break
			StringGetPos, x, str, %quot%,, % x + 1
		}
	;	StringReplace, str, str, %quot%%t%%quot%, %quot% ; this might corrupt the string
		str := ( z ? SubStr( str, 1, z ) : "" ) quot SubStr( str, x + 2 ) ; this won't

	; Decode entities
		StringReplace, key, key, \%quot%, %quot%, A
		StringReplace, key, key, \b, % Chr(08), A
		StringReplace, key, key, \t, % A_Tab, A
		StringReplace, key, key, \n, `n, A
		StringReplace, key, key, \f, % Chr(12), A
		StringReplace, key, key, \r, `r, A
		StringReplace, key, key, \/, /, A
		while y := InStr( key, "\u", 0, y + 1 )
			if ( A_IsUnicode || Abs( "0x" SubStr( key, y + 2, 4 ) ) < 0x100 )
				key := ( y = 1 ? "" : SubStr( key, 1, y - 1 ) ) Chr( "0x" SubStr( key, y + 2, 4 ) ) SubStr( key, y + 6 )

		literals.insert(key)

		StringGetPos, z, str, %quot%,, % z + 1 ; seek
	}

; Second pass parses the markup and builds the object iteratively, swapping placeholders as they are encountered
	key := isarray := 1

	; The outer loop splits the blob into paths at markers where nest level decreases
	Loop Parse, str, % "]}"
	{
		StringReplace, str, A_LoopField, [, [], A ; mark any array open-brackets

		; This inner loop splits the path into segments at markers that signal nest level increases
		Loop Parse, str, % "[{"
		{
			; The first segment might contain members that belong to the previous object
			; Otherwise, push the previous object and key to their stacks and start a new object
			if ( A_Index != 1 )
			{
				objs.insert( obj )
				isarrays.insert( isarray )
				keys.insert( key )
				obj := {}
				isarray := key := Asc( A_LoopField ) = 93
			}

			; arrrrays are made by pirates and they have index keys
			if ( isarray )
			{
				Loop Parse, A_LoopField, `,, % ws "]"
					if ( A_LoopField != "" )
						obj[key++] := A_LoopField = quot ? literals.remove(1) : A_LoopField
			}
			; otherwise, parse the segment as key/value pairs
			else
			{
				Loop Parse, A_LoopField, `,
					Loop Parse, A_LoopField, :, % ws
						if ( A_Index = 1 )
							key := A_LoopField = quot ? literals.remove(1) : A_LoopField
						else if ( A_Index = 2 && A_LoopField != "" )
							obj[key] := A_LoopField = quot ? literals.remove(1) : A_LoopField
			}
			nest += A_Index > 1
		} ; Loop Parse, str, % "[{"

		If !--nest
			Break

		; Insert the newly closed object into the one on top of the stack, then pop the stack
		pbj := obj
		obj := objs.remove()
		obj[key := keys.remove()] := pbj
		If ( isarray := isarrays.remove() )
			key++

	} ; Loop Parse, str, % "]}"

	Return obj
} ; json_toobj( str )


;0-Blank
;1-BS15
;2-GIS15
;3-GYS15
;4-SP15
;5-TSP15
;6-TUC15
;7-TUS15
;8-UC15
;9-US15


