Startup:
{
#SingleInstance force
#WinActivateForce
SendMode Input    
SetTitleMatchMode, 2
ComObjError(false)

urlQueue := "https://dazzling-torch-3393.firebaseio.com/CassettePrinting.json"
baseYear=15
global ie := IEGet()  ;Gets or creates the open LIS Window logged into LIS, declares ie to be global object for all future LIS functions.
global baseCaseLabel := ""
global urlQueue

return
}

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
		If Instr( pwb.Document.url, "portal.averodx.com")
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

BuildStandardGUI()
{
	global
	guiType := "Standard"
	Gui, Destroy
	Gui, Font, S12, Arial
	Gui, Add, Text, vcaseNumText, Case Number: %caseNum%
	Gui, Add, Text, vfullNameText ,%fullName%
	Gui, Add, Text, vjarCountText, Total Jars: %jarCount%

	Loop, %jarCount%
	{
		offset := 80+ A_Index *30
		jarLabel := jar%A_Index%
		Gui, Add, Text, x22 y%offset% w50 h28, %jarLabel%
		Gui, Add, Edit, x82 y%offset% w50 h28 vjar%A_Index%Quantity
		Gui, Add, UpDown, vMyUpDown%A_Index% Range1-100, 1
	}
		offset := offset + 50
		Gui, Add, Button, x20 y%offset% w60 h28 Default, Send
		Gui, Add, Button, x85 y%offset% w60 h28 Cancel, Cancel
		Gui, Add, Button, x150 y%offset% w150 h28 vswitchTemplate, Switch Template

Return
}

BuildUSGUI()
{
	global
	skipNext := false
	Gui, Destroy
	Gui, Font, S12, Arial
	Gui, Add, Text, vcaseNumText, Case Number: %caseNum%
	Gui, Add, Text, vfullNameText ,%fullName%
	Gui, Add, Text, vjarCountText, Total Jars: %jarCount%
	guiType := "US"
	Loop, %jarCount%
	{
		if (skipNext)
		{
			skipNext := false
			key%A_Index% := "SKIP"
			continue
		}
		
		if (A_Index=1)
			offset := 80+ A_Index *30
		else
			offset := offset + 30
		
		nextIndex := A_Index + 1
		
		jarLabel := jar%A_Index%
		jarLabelNext := jar%nextIndex%
		
		if ((jarLabel="A" and jarLabelNext="B") or (jarLabel="C" and jarLabelNext="D") or (jarLabel="E" and jarLabelNext="F") or (jarLabel="G" and jarLabelNext="H") or (jarLabel="I" and jarLabelNext="J") or (jarLabel="K" and jarLabelNext="L") or (jarLabel="M" and jarLabelNext="N") or (jarLabel="O" and jarLabelNext="P"))
		{
			;Do a combined box and skip next iteration of the loop, Print Label Quantity 1 Split check box
			key%A_Index% := "PLS"
		    Gui, Add, CheckBox, x22 y%offset% w62 h28 v%A_Index%Print Checked, Print?
			%A_Index%Label=%jarLabel%/%jarLabelNext%
			Gui, Add, Text, x122 y%offset% w99 h28, %jarLabel%/%jarLabelNext%
			Gui, Add, CheckBox, x172 y%offset% w102 h28 v%A_Index%Split , Split?
			skipNext := true
		}
		else 
		{
			;Do Individual box for jar label only and don't skip, Print? Label Quantity 1
			key%A_Index% := "LQ"
			%A_Index%Label=%jarLabel%
			Gui, Add, Text, x22 y%offset% w99 h30 v%A_Index%Label, %jarLabel%
			Gui, Add, Edit, x82 y%offset% w50 h28 v%A_Index%Quantity
			Gui, Add, UpDown, vMyUpDown%jarLabel% Range0-100, 1
			skipNext := false
		}
		
	}

		Gui, Add, Button, x20 y315 w60 h28 Default, Send
		Gui, Add, Button, x85 y315 w60 h28 Cancel, Cancel
		Gui, Add, Button, x150 y315 w150 h28 vswitchTemplate, Switch Template

return
}

ButtonSwitchTemplate:
{
if (guiType="US")
	BuildStandardGUI()
else if (guiType="Standard")
	BuildUSGUI()

Gui, Show, ,  %A_ScriptName% 
return
}

ButtonSend:
{
	Gui, Submit
	if (guiType="US")
		SendUS()
	else if (guiType="Standard")
		SendStandard()
	
	return
}

GuiClose:
ButtonCancel:
{
	Gui, Cancel
	return
}

F12::
{
	
orderingLocation := ie.document.getElementById("orderModelOrderingLocationTable").value
patient := ie.document.getElementById("patient_order_search").value
mrn := ie.document.getElementById("mrn").value
orderingProvider := ie.document.getElementById("orderModelOrderingProviderTable").value
collectionLocation := ie.document.getElementById("select_patientDrawLocation").value
orderDateMonth := ie.document.getElementById("orderDate_month").value
orderDateDay := ie.document.getElementById("orderDate_day").value
orderDateYear := ie.document.getElementById("orderDate_year").value

ie.document.getElementById("select_patientDrawLocation_search").click()
Sleep, 500
ie.document.getElementById("datatableTableBasepatientDrawLocationTable_extraButtons").firstChild.firstChild.click()

;Msgbox, %orderingLocation%`n%patient%`n%orderingProvider%
return

}

indexToControlNumber(index)
{
	x := index + 1
	y=%x%
	
	if x<10
		y =0%x%

return y
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

CassetteMagazineType(prefix)
{
	global
	if (shortPrefix="TUS")
		magToUse := "Magazine 1"
	else if (shortPrefix="SP" AND clientName!="Craig Ranch OBGYN (Craig Ranch OBGYN)")
		magToUse := "Magazine 2"
	else if (shortPrefix="US") ;Add exception for craig ranch
		magToUse := "Magazine 3"
	else if (shortPrefix="GYS" OR (shortPrefix="SP" AND clientName="Craig Ranch OBGYN (Craig Ranch OBGYN)"))
		magToUse := "Magazine 4"
	else if (shortPrefix="GIS")
		magToUse := "Magazine 5"
	else if (shortPrefix="BS")
		magToUse := "Magazine 6"
	

	return magToUse
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

SendStandard()
{
	global
	j := CassetteMagazineType(prefix)
	dataheader={"prefix":"%prefix%", "accessionNumber":"%accessionNumber%", "fullName":"%fullName%"
	dataheader=%dataheader%, "cassetteMagazine":"%j%", "data":{
	datafooter=}}
	
	Loop, %jarCount%
	{
		jarLabel := jar%A_Index%
		jarQuantity := jar%A_Index%Quantity - 1 
		if (jarQuantity>0)
			printdata="blockLetter":"%jarLabel%", "blockLetterQuantity":"", "specimenNumber":"1", "specimenNumberQuantity":"%jarQuantity%"
		else
			printdata="blockLetter":"%jarLabel%", "blockLetterQuantity":"", "specimenNumber":"", "specimenNumberQuantity":""
	
	data=%dataheader%%printdata%%datafooter%
	URLPost(urlQueue, data)
	}
	
	return
}

SendUS()
{
	global
	j := CassetteMagazineType(prefix)
	dataheader={"prefix":"%prefix%", "accessionNumber":"%accessionNumber%", "fullName":"%fullName%"
	dataheader=%dataheader%, "cassetteMagazine":"%j%", "data":{
	datafooter=}}
	
	Loop, %jarCount%
	{
		thisKey := key%A_Index%
		if (thisKey="SKIP")
			continue
		else if(thisKey="LQ")
		{
			jarLabel := %A_Index%Label
			jarQuantity := %A_Index%Quantity  
			if (jarQuantity>0)
				printdata="blockLetter":"%jarLabel%", "blockLetterQuantity":"", "specimenNumber":"1", "specimenNumberQuantity":"%jarQuantity%"
			else
				printdata="blockLetter":"%jarLabel%", "blockLetterQuantity":"", "specimenNumber":"", "specimenNumberQuantity":""
	
			data=%dataheader%%printdata%%datafooter%
			URLPost(urlQueue, data)
		}
		else if(thisKey="PLS")
		{
			firstLetter := SubStr(%A_Index%Label,1,1)
			secondLetter := SubStr(%A_Index%Label,3,1)
			
			if (%A_Index%Print)
			{
				if (%A_Index%Split)
					printdata="blockLetter":"%firstLetter%", "blockLetterQuantity":"1", "specimenNumber":"", "specimenNumberQuantity":""
				else
					printdata="blockLetter":"%firstLetter%/%secondLetter%", "blockLetterQuantity":"", "specimenNumber":"", "specimenNumberQuantity":""
			
			data=%dataheader%%printdata%%datafooter%
			URLPost(urlQueue, data)
			}
		}
		
		nextIndex := A_Index + 1
		
		jarLabel := jar%A_Index%
		jarLabelNext := jar%nextIndex%
	}

return
}


ScrollLock::Suspend	
^!v::ListVars   ;List the variables currently in memory.
^!l::ListLines  ;List the most recently executed lines of code.
Pause::Pause
^!r::Reload
/*
{
PossibleDrives=ZYXWVUTSRQPONMLKJIHGFE

version:=URLDownloadToVar("https://dazzling-torch-3393.firebaseio.com/AveroQueue/Settings/cassSendVersion.json")

StringReplace, version, version, ",,All

Loop, Parse, PossibleDrives
	IfExist, %A_LoopField%:\LNT\cassLink\cassSend-%version%.ahk
	{
		Run, %A_LoopField%:\LNT\lib\Autohotkey\Autohotkey.exe %A_LoopField%:\LNT\cassLink\cassSend-%version%.ahk
		break
	}
}
*/
