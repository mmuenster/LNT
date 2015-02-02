global validhelpers=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890
global letters=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
global numbers=1234567890

get_filled_case_number(c)
{
    StringUpper c,c
	ret := ""
    StringSplit,arr,c,-
	if (arr0 = 2) {
        stringlen,len,arr2
		repeatnum := 6-len
		zeros:=""
		cnt := 0
		While (cnt < repeatnum){
			cnt := cnt +1
			zeros:=zeros . "0"
		}
		ret := arr1 . "-" . zeros . arr2
	}		
	return ret
} 
	
ParseQAQCData()
{
	global

msg = 

/*  Sample code for Margin checking - not ever finished 
Stringlen, x, backtophelp
				If (x > 1)    ;MULTIPLE MARGIN CODES WERE ENTERED
					{
					Msgbox, You may only enter one margin code!
					return, 1
					}
				else if (x=1)  ;MARGIN CODE WAS ENTERED
					{
						if SelInf
						{
							Msgbox, 4, ,The diagnosis code you selected is "inflammatory" and you gave a margin.  Are you sure you wish to continue?
							IfMsgbox No
								Return 1
						}
						else if SelMal
						{
							if (MarginNoPreference OR MarginMalignant OR MarginAll)
								Return 0
							Else
							{
								Msgbox, 4, , The client has not requested to have margins on 
							}
						}
						else if SelDys
						{
						}
						else if SelMel
						{
						}
						else if SelPre
						{
						}
							
					}
				else if (x=0)   ;MARGIN CODE WAS NOT ENTERED
					{
						;Margin Checking to ensure lack of margin information is ok goes here.
					}
*/
	
OrderedCPTCodes:   ;OrderedCPTCodeX  OrderedCPTCount
{
OrderedCPTCount = 0
Loop, Parse, OrderedCPTCodes, CSV	
			{
			OrderedCPTCode%A_Index% = %A_LoopField%	
			OrderedCPTCount := A_Index
			}
		msg = %msg%OrderedCPTCount = %OrderedCPTCount%, %OrderedCPTCode1%, %OrderedCPTCode2%`n
}

GrossDescription:   ;For up to ten vials, grosstext_X, GrossVialCount
{

	StringCaseSense, On
	PositionNotFound := 0
	GrossVialCount := 0
	pos_0 := 0	

	Loop, 26
		{
		grosstext_%A_Index% = 	
		pos_%A_Index% =
		ascii_code := Chr(64+A_Index)
			
		StringGetPos, pos_%A_Index%, grossdescriptiontext, %ascii_code%.%A_Space%		
		If (Errorlevel AND A_Index=1)
			{
			StringCaseSense, Off
			StringGetPos, pos_1, grossdescriptiontext, received
			if Errorlevel
				msg = %msg%The gross description could contain an error because no information for "A. " could be found. `n	
			Else
				{
				GrossVialCount := 1	
				grosstext_1 = %grossdescriptiontext%
				Break
				}
			}

	GrossVialCount := A_Index - 1
	if pos_%A_Index% > 0
		l := pos_%A_Index% - pos_%GrossVialCount% - 1
	Else
		l := StrLen(grossdescriptiontext)
		
	StringMid, grosstext_%GrossVialCount%, grossdescriptiontext, pos_%GrossVialCount%, %l%
	If ErrorLevel
		Break
		}
	StringCaseSense, Off
}

FinalDiagnosis:    ;finaltext_x, biopsytype_X, FinalVialCount
{
		msg=%msg%GrossVialCount=%GrossVialCount%|| %grosstext_1%|| %grosstext_2%`n
		Needle := "%%P%%"
		i := 0
		h := 0
		k := 1

		Loop, 26
		{
			biopsytype_%A_Index% =
			finaltext_%A_Index% = 
		}
		
		Loop, 26
		{
			StringGetPos, i, finaldiagnosistext, %Needle%, , %k%
			if i>0
				{
				j := i - k
				h := h + 1
				StringMid, finaltext_%A_Index%, finaldiagnosistext, %k%+1, %j%
				k := i + 6
				StringGetPOs, y, finaltext_%A_Index%, shave
					if y>0
						biopsytype_%A_Index% = shave
				StringGetPOs, y, finaltext_%A_Index%, punch
					if y>0
						biopsytype_%A_Index% = punch
				StringGetPOs, y, finaltext_%A_Index%, excision
					if y>0
						biopsytype_%A_Index% = excision
				StringGetPOs, y, finaltext_%A_Index%, curettage
					if y>0
						biopsytype_%A_Index% = curettage
				StringReplace, finaltext_%A_Index%, finaltext_%A_Index%,*** ,,All
				}
			Else
				Break
		}
	
	FinalVialCount := h
	msg = %msg%FinalVialCount =%FinalVialCount%|| %finaltext_1%|| %finaltext_2%`n
/*
Loop, %FinalVialCount%
		{
			StringcaseSense, Off
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%R%A_space%, %A_Space%Right%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%R.%A_space%, %A_Space%Right%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%Rt%A_space%, %A_Space%Right%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%Rt.%A_space%, %A_Space%Right%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%L%A_space%, %A_Space%Left%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%L.%A_space%, %A_Space%Left%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%Lt%A_space%, %A_Space%Left%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%Lt.%A_space%, %A_Space%Left%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%abd%A_space%, %A_Space%abdomen%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%lat%A_space%, %A_Space%lateral%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%med%A_space%, %A_Space%medial%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%prox%A_space%, %A_Space%proximal%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%dist%A_space%, %A_Space%distal%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%bx%A_space%, %A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%bx., %A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%bx:, %A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%bx.:, %A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%post%A_space%, %A_Space%posterior%A_Space%
			StringReplace, finaltext_%A_Index%,finaltext_%A_Index%, %A_Space%ant%A_space%, %A_Space%anterior%A_Space%
		}
*/

		}

ClinicalData:
{
	StringCaseSense, On
	PositionNotFound := 0
	ClinDataVialCount := 0
	pos_0 := 0	

	Loop, 26
		{
		clindata_%A_Index% = 	
		pos_%A_Index% =
		ascii_code := Chr(64+A_Index)
			
		StringGetPos, pos_%A_Index%, ClinicalData, %ascii_code%.%A_Space%		
		If (Errorlevel AND A_Index=1)
			{
				StringCaseSense, Off
				ClinDataVialCount := 0	
				clindata_1 = %ClinicalData%
				Break				
			}

	ClinDataVialCount := A_Index - 1
	if (pos_%A_Index% > 0 AND pos_%A_Index% > pos_%ClinDataVialCount%)
		l := pos_%A_Index% - pos_%ClinDataVialCount% - 1
	Else
		l := StrLen(ClinicalData)
		
	StringMid, clindata_%ClinDataVialCount%, ClinicalData, pos_%ClinDataVialCount%, %l%
	If ErrorLevel
		Break
	}
	StringCaseSense, Off
	If ClinDataVialCount =0
		ClinDataVialCount = 1
	msg = %msg%%ClinDataVialCount%||%clindata_1%||%clindata_2%`n	
}
		
Return
}

ParseCheckandPullDiagnosis(DxCode)
{
	global
	SelectedCodeIndex := 0
	
	Stringlen, ltot, DxCode
	StringGetPos, j, DxCode,.
	StringGetPos, k, DxCode,;
	StringGetPos, i, DxCode,:
		
	if k=-1
		comhelp = 
	Else
		{
			x := ltot - k - 1
			StringRight, comhelp, DxCode, x
		}
	
	Stringlen, comlength, comhelp
	If (comlength>0)
		comlength := comlength + 1
		
	if j=-1
		backtophelp = 
	Else
		{
		if k=-1
			x :=  ltot - j -1
		Else
			x := k - j - 1
			
		xstart := j + 2
		StringMid, backtophelp, DxCode, xstart, x
		}

	Stringlen, backlength, backtophelp
	If (backlength>0)
		backlength := backlength + 1

	if i=-1
		{
		fronttophelp =	
		baselength := ltot - comlength - backlength
		StringLeft, basediag, DxCode, baselength
		}					
	Else
		{
		StringLeft, fronttophelp, DxCode, i	
		Stringlen, frontlength, fronttophelp
		frontlength := frontlength + 1
		xstart := i + 2
		x := ltot - comlength - backlength - frontlength
		StringMid, basediag, DxCode, xstart, x
		}
	
		;Msgbox, %fronttophelp%`n%basediag%`n%backtophelp%`n%comhelp%
	Loop % LV_GetCount()
		{
		LV_GetText(RetrievedText, A_Index, 2)
		if basediag=%RetrievedText%
			{
			LV_Modify(A_Index, "Select")  ; Select each row whose first field contains the filter-text.
			SelectedCodeIndex = %A_Index%
			Break
			}
		}

	If (SelectedCodeIndex = 0 OR ltot=0)
		{
		Msgbox, That is not a valid diagnosis code!
		return, 1
		}
	
	
	LV_GetText(SelDXCode,SelectedCodeIndex,2)  
	LV_GetText(SelDiagnosis,SelectedCodeIndex,5)  
	LV_GetText(SelComment,SelectedCodeIndex,6)
	LV_GetText(SelMicro,SelectedCodeIndex,7)
	LV_GetText(SelCPTCode,SelectedCodeIndex,8)
	LV_GetText(SelICD9,SelectedCodeIndex,9)
	LV_GetText(SelICD10,SelectedCodeIndex,10)
	LV_GetText(SelSnomed,SelectedCodeIndex,11)
	LV_GetText(SelPre,SelectedCodeIndex,12)
	LV_GetText(SelMal,SelectedCodeIndex,13)
	LV_GetText(SelDys,SelectedCodeIndex,14)
	LV_GetText(SelMel,SelectedCodeIndex,15)				
	LV_GetText(SelInf,SelectedCodeIndex,16)
	LV_GetText(SelMargInc,SelectedCodeIndex,17)
	LV_GetText(SelLog,SelectedCodeIndex,18)
	return 0
}

MicroCodeEntered(RawDxCode)
{
	IfInstring, RawDxCode, /
		Return, 1
	else
		Return, 0
}

ICD9sCodeEntered(RawDxCode)
{
	IfInstring, RawDxCode, *
		Return, 1
	else 
		Return, 0
}

ConstructDiagnosisLine()
{
	global
	;Loop to add front helper codes to the diagnosis
	Stringlen, i, fronttophelp
	Loop, %i%
	{
		x := i + 1 - A_Index
		StringMid, j, fronttophelp, x, 1
		p := FrontofDiagnosisHelper%j%
		SelDiagnosis = %p% %SelDiagnosis%
	}

	;Replace all /-/ from the diagnosis with new line characters
	cr = `n
	StringReplace, SelDiagnosis, SelDiagnosis, /-/, %cr%, All

	;Split Multiline diagnoses into first line and rest of diagnosis
	IfInString, SelDiagnosis, %cr%
		StringGetPos, x, SelDiagnosis, %cr%
	else
		StringLen, x, SelDiagnosis
	StringLen, l, SelDiagnosis
	StringLeft, DiagFirstLine, SelDiagnosis, %x%
	y := l - x
	StringRight, RestofDiag, SelDiagnosis, %y%
	
	;Add margin code (backtophelp) to first line only of the diagnosis.
	if (p := BackofDiagnosisHelper%backtophelp%)
		DiagFirstLine = %DiagFirstLine%; %p%
		
	;Ensures that a period is put at the end of the diagnosis line if one does not exist already.
	StringRight, lastletter, DiagFirstLine, 1
	if lastletter<>.
		DiagFirstLine = %DiagFirstLine%.

	;If selected, add the ICD9 code to the diagnosis line
	if (TempICD9s OR UseICD9s)
		{
			if SelICD9
			{
				if SelICD9 is integer  ;Add .0 to codes that are integers
					SelICD9 = %SelICD9%.0
				DiagFirstLine = %DiagFirstLine% (%SelICD9%)
			}
			Else
			{
				DiagFirstLine = %DiagFirstLine% (***)
				SoundBeep  ;Beep to alert that ICD9 code is blank
			}
		}
t =%DiagFirstLine%%RestofDiag%
return t
}

ConstructCommentLine()
{
	global
	;Loop to add comment helper codes to the comment
	Stringlen, i, comhelp
	Loop, %i%
	{
		StringMid, j, comhelp, %A_Index%, 1
		p := CommentHelper%j%
		SelComment = %SelComment%  %p%  `
	}

	;Replace all /-/ from the diagnosis with new line characters
	StringReplace, SelComment, SelComment, /-/, %cr%, All
	
	If ((TempMicros OR UseMicros) AND !SelMicro)
	{
		SoundBeep
		Msgbox, Client has requested microscopic descriptions and there is not one for this diagnostic code!  Please enter manually.
	}
	
	commenttext := ""
	If (SelComment or (SelMicro and (TempMicros OR UseMicros)))
		{
		If (TempMicros OR UseMicros)
			commenttext = Comment:%A_Space%%SelComment%%A_Space%%A_Space%%SelMicro%
		Else
			commenttext = Comment:%A_Space%%SelComment%
		}
	
	return, commenttext
}

CreateHelperListGui()  ;This is currently numbered as GUI #3
{           
	df =FRONT OF DIAGNOSIS HELPERS`n
	df=%df%------------------------------------------------------`n
	Loop, 10
		{
			x := A_index -1 
			ph1 := FrontofDiagnosisHelper%x%
			df = %df%%x% -- %ph1%`n
		}
	Loop, 26
		{
			x := Chr(64 + A_Index)
			ph1 := FrontofDiagnosisHelper%x%
			df = %df%%x% -- %ph1%`n
		}
	df = %df%----------------------------------------------------`n

	dm =MARGIN HELPERS`n---------------------------------------------------------------------------------`n
	Loop, 10
		{
			x := A_index -1 
			ph1 := BackofDiagnosisHelper%x%
			dm = %dm%%x% -- %ph1%`n
	    }
	Loop, 26
		{
			x := Chr(64 + A_Index)
			ph1 := BackofDiagnosisHelper%x%
			dm = %dm%%x% -- %ph1%`n
		}
	dm = %dm%---------------------------------------------------------------------------------`n

dc =COMMENT HELPERS`n---------------------------------------------------------------------------------`n
	Loop, 10
		{
			x := A_index -1 
			ph1 := CommentHelper%x%
			dc = %dc%%x% - %ph1%`n
		}
	Loop, 26
		{
			x := Chr(64 + A_Index)
			ph1 := CommentHelper%x%
			dc = %dc%%x% - %ph1%`n
		}

	dc = %dc%---------------------------------------------------------------------------------`n
Gui, 3:Font, S8, Verdana
Gui, 3:Add, Text, w150, %df%
Gui, 3:Add, Text, w100 ym, %dm%
Gui, 3:Add, Text, w200 ym, %dc%

return
}

