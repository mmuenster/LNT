;LIS SPECIFIC FUNCTION

ComObjError(false)
global ie := IEGet()  ;Gets or creates the open LIS Window logged into LIS, declares ie to be global object for all future LIS functions.
global baseCaseLabel := ""
global urlQueue

IELoad(Pwb)	;Waits until the requested page is completely loaded before returning
{
	If !Pwb	;If Pwb is not a valid pointer then quit
		Return False
	Loop	;Otherwise sleep for .1 seconds untill the page starts loading
		Sleep,100
	Until (Pwb.busy)
	Loop	;Once it starts loading wait until completes
		Sleep,100
	Until (!Pwb.busy)
	Loop	;optional check to wait for the page to completely load
		Sleep,100
	Until (Pwb.Document.Readystate = "Complete")
Return True
}

IEGet( name="" ) ;Gets the open IE window (must already be logged into Vital Axis) or opens and logs in if not done already.
{
	candidate := ""
	
	For pwb in ComObjCreate( "Shell.Application" ).Windows
      If InStr( pwb.FullName, "iexplore.exe" )
		If Instr( pwb.Document.url, "path.averodx.com")
			if (pwb.Visible = -1)   ;Returns -1 when visible, 0 when hidden
				{
				candidate := pwb
				if (pwb.getProperty("WinNum") = 1)
					j := pwb
				}
		
	If !j and !candidate
		{
			Msgbox, No active Internet Explorer window logged into the LIS was found!
			ExitApp
		}
	else 
		{
			if !j and candidate
				j := candidate
			j.putProperty("WinNum", 1)
			j.Visible := True
			;j.TheaterMode := true
			j.AddressBar := true
			Return j
		}
}

LISGotoNextBlankorJar()
{
			curSelection := ie.document.selection.createRange()
			curSelection.collapse(false)
			if (curSelection.findText("***"))
				{
					curSelection.select()
					;LISSetDiagnosisTextArea("")  ;When no text sent, just sets the focus
					WinActivate, Internet Explorer
					Return True
				}
			else
			{
				curSelection.moveStart("character", -10000)
				if (curSelection.findText("***"))
					{
						curSelection.select()
						;LISSetDiagnosisTextArea("")  ;When no text sent, just sets the focus
						WinActivate, Internet Explorer
						Return True
					}
			}
			return False

}

LISReplaceDxCodeWithFullDiagnosis(DxCode,DiagnosisLineText,CommentLineText,CPTandDXCodeDataStructure,SelICD9,UseSendMethod)
{  ;Enters all data and returns the cursor to the Beginning of the diagnosis line 
			clipboard = %DiagnosisLineText%`n`n%CommentLineText%`n
			return
}

LISBuildCPTandDXCodeDataStructure(SelCPTCode, SelDxCode)
{
	If SelCPTCode
		{
			CPTandDXCodes =~~
			Loop, parse, SelCPTCode,`;
				{
					if A_Index > 1
						CPTandDXCodes =  %CPTandDXCodes%|
					else
						CPTandDXCodes = %CPTandDXCodes%%A_LoopField%	
				}
			CPTandDXCodes = %CPTandDXCodes%~~
		}
	return, CPTandDXCodes
}

LISBuildHeader()
{
	i := ie.document.getElementById("ctl00_DefaultContent_ResultPanel_ctl00_ResultControlPanel").firstChild.rows.length
	headerText := ""
	Loop, %i%
	{
		; j is the letter of the specimen, k is the site, and l is the gross description
		j := ie.document.getElementById("ctl00_DefaultContent_ResultPanel_ctl00_ResultControlPanel").firstChild.rows[A_Index-1].cells[0].firstChild.firstChild.rows[0].childNodes[0].childNodes[0].innerHTML
		j := Substr(j,1,1)
			k := ie.document.getElementById("ctl00_DefaultContent_ResultPanel_ctl00_ResultControlPanel").firstChild.rows[A_Index-1].cells[0].firstChild.firstChild.rows[0].childNodes[1].childNodes[0].value
			l := ie.document.getElementById("ctl00_DefaultContent_ResultPanel_ctl00_ResultControlPanel").firstChild.rows[A_Index-1].cells[0].firstChild.firstChild.rows[0].childNodes[2].childNodes[0].childNodes[0].innerHTML
	procedureString := LISReturnProcedureFromGross(l)
	StringUpper, k, k, T   ;convert to Title case
	if procedureString=
		headerText = %headerText%%j%) %k%:`n***`n`n
	else
		headerText = %headerText%%j%) %k%, %procedureString%:`n***`n`n
	}
	
	
	Return headerText
}

LISReturnProcedureFromGross(gross)
{
	ShavePos := RegExMatch(gross, "(sb.)") + RegExMatch(gross, " shave ")
	PunchPos := RegExMatch(gross, "(pb.)") + RegExMatch(gross, " punch ")
	ExcisionPos := RegExMatch(gross, "(ex.*)") + RegExMatch(gross, " ellipt")
	
	If ShavePos>0
		Return "Shave Biopsy"
	else if PunchPos>0
		REturn "Punch Biopsy"
	else if ExcisionPos>0
		Return "Excision"
	else if NailPos>0
		Return "Nail Clipping"
	else if ExcisionalBiopsyPos>0
		Return "Excisional biopsy"
	else
		Return ""
}

LISQueueCPTEditsAndResave(Casenum, codestring, resave) {

	data={"action":"cptDeletes", "caseNumber":"%CaseNum%"}
	url:="https://dazzling-torch-3393.firebaseio.com/AveroQueue.json"
	j := URLPost(url, data)
	Sleep, 500
	data={"action":"cptAdds", "caseNumber":"%CaseNum%", "cptCodes":"%codestring%" }
	url:="https://dazzling-torch-3393.firebaseio.com/AveroQueue.json"
	j := URLPost(url, data)
	Sleep, 500
	if(resave)
	{
		data={"action":"pdfSave", "caseNumber":"%CaseNum%"}
		url:="https://dazzling-torch-3393.firebaseio.com/AveroQueue.json"
		j := URLPost(url, data)
	}
	
	return
}


LISDeletePDFReviewAction(k){
		data={}
		url=https://dazzling-torch-3393.firebaseio.com/AveroQueue/%k%.json
		j := URLDelete(url, data)
return
}

LISQueueSignout(Casenum){
	data={"action":"signout", "caseNumber":"%CaseNum%"}
	j := URLPost(urlQueue, data)
	Sleep, 500
	Return
}



;EXTERNAL DATABASE FUNCTIONS
{
GetUserSettings(url)
{
	p := UrlDownloadToVar(url)
	return JsontoObject(p)
}

URLDownloadToVar(url){
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	return hObject.ResponseText
}

UrlDelete(URL, data){
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


FirstTimeSetup()
{
	Return
}

ReadDXCodes()
{
	global
	LV_Delete()
	
	;Diagnosis Codes Load
	/*
	if FileExist("%A_ScriptDir%/diagnosisCodes.json")
		FileRead, t, %A_ScriptDir%/diagnosisCodes.json
	else
	{
	*/
	t := UrlDownloadToVar("https://dazzling-torch-3393.firebaseio.com/newDiagnosisCodes.json")
		;FileAppend, %t%, %A_ScriptDir%/diagnosisCodes.json
	
	fh := JsonToObject(t)
	For k, v in fh
		{
		DXCode1 := k
		DXCode2 := v[1]
		DXCode3 := v[2]
		DXCode4 := v[3]
		DXCode5 := v[4]
		DXCode6 := v[5]
		DXCode7 := v[6]
		DXCode8 := v[7]
		DXCode9 := v[8]
		DXCode10 := v[9]
		LV_Add("","",DXCode1,DXCode2,DXCode3,DXCode4,DXCode5,DXCode6,DXCode7,DXCode8,DXCode9,DXCode10)   ;DXCode11,DXCode12,DXCode13,DXCode14,DXCode15,DXCode16,DXCode17,DXCode18
		}

	LV_ModifyCol()  ; Auto-size each column to fit its contents. 
	LV_Modify(1, "Sort")
		t := ""
		fh := "" ;Free memory
	return
	
}

ReadHelpers()
{
	global

;Margin Load
	t := UrlDownloadToVar("https://dazzling-torch-3393.firebaseio.com/marginHelpers.json")
	fh := JsonToObject(t)
	For k, v in fh
		BackofDiagnosisHelper%k% = %v%

;Front Helper Load	
	t := UrlDownloadToVar("https://dazzling-torch-3393.firebaseio.com/frontHelpers.json")
	fh := JsonToObject(t)
	For k, v in fh
		FrontofDiagnosisHelper%k% = %v%

;Comment Helper Load	
	t := UrlDownloadToVar("https://dazzling-torch-3393.firebaseio.com/commentHelpers.json")
	fh := JsonToObject(t)
	For k, v in fh
		CommentHelper%k% = %v%
	
	t := ""
	fh := "" ;Free memory
	
}

CodeDatabaseQuery(s)
{
global
RetryCodeDatabase:
	Loop, 15          ;Blank the results array
		Result_%A_Index% =
	
	connectstring := "Driver={MySQL ODBC 3.51 Driver}; SERVER= mysql.drmuenster.com; DATABASE=code_base; UID= mmuenster; PASSWORD=Tehawud32#; OPTION=3"	
	adodb := ComObjCreate("ADODB.Connection")
	rs := ComObjCreate("ADODB.Recordset")
	rs.CursorType := "0"
	adodb.open(connectstring)
	rs := adodb.Execute(s)	
	
	If A_LastError
		{
			Msgbox, 4101, Error Message, There was an error accessing the Code Database.`n  `ns=%s%`n  A_LastError = %A_LastError%
			IfMsgbox, Retry
				Goto, RetryCodeDatabase	
			else ifMsgBox, Cancel
				ExitApp
		}	
		
	msg := ""
	txt := rs.state
	If !txt
		return
		
	while rs.EOF = 0{
		for field in rs.fields
			msg := msg . "¥" . Field.Value
		rs.MoveNext()
	}
	
	Loop, parse, msg, ¥ 
		{
		if (A_Index = 1)
			Continue
		Else
			{
			 i := A_Index -1 
			 Result_%i% := A_LoopField		
			}
		}

	rs.close()   
	adodb.close()
	return msg	
}

}