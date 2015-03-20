Startup:
{
#SingleInstance force
#WinActivateForce
SendMode Input    
SetTitleMatchMode, 2
SetTitleMatchMode, Slow
ComObjError(false)

;HKEY_CLASSES_ROOT\Software\Adobe\Acrobat\Exe
	RegRead, AdobeReader, HKCR, Software\Adobe\Acrobat\Exe
	StringReplace, AdobeReader, AdobeReader, `", , A

urlQueue := "https://dazzling-torch-3393.firebaseio.com/CassettePrinting.json"
slideQueue := "https://dazzling-torch-3393.firebaseio.com/SlidePrinting.json"

baseYear=15
global ie := IEGet()  ;Gets or creates the open LIS Window logged into LIS, declares ie to be global object for all future LIS functions.
global baseCaseLabel := ""
global urlQueue

SetTimer, KeepHerokuUp, 720000
Gosub, KeepHerokuUp
return
}

KeepHerokuUp:
{
	p:=URLDownloadToVar("http://obscure-spire-2273.herokuapp.com/key/buster")
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

BuildStandardGUI()
{
	global
	guiType := "Standard"
	;Msgbox, caseNum=%caseNum%
	Gui, Destroy
	Gui, Font, S12, Arial
	Gui, Add, Text, vcaseNumText, Case Number: %caseNum%
	Gui, Add, Text, vfullNameText ,%fullName%
	Gui, Add, Text, vjarCountText, Total Jars: %jarCount%
	Gui, Add, Text, x172 y70, P6 
	Gui, Add, Text, x222 y70, L1-3
	Gui, Add, Text, x272 y70, L1L2
	Gui, Add, Text, x322 y70, L1L2L3 
	PrinterChooser()
	
	Loop, %jarCount%
	{
		offset := 80+ A_Index *30
		jarLabel := jar%A_Index%
		Gui, Add, Text, x22 y%offset% w50 h28, %jarLabel%
		Gui, Add, Edit, x82 y%offset% w50 h28 vjar%A_Index%Quantity
		Gui, Add, UpDown, vMyUpDown%A_Index% Range1-100, 1
		Gui, Add, CheckBox, x172 y%offset% h28 v%A_Index%P6
		Gui, Add, CheckBox, x222 y%offset% h28 v%A_Index%L1to3
		Gui, Add, CheckBox, x272 y%offset% h28 v%A_Index%L1L2 
		Gui, Add, CheckBox, x322 y%offset% h28 v%A_Index%L1L2L3 
	}
		offset := offset + 50
		Gui, Add, Button, x20 y%offset% w60 h28 Default, Send
		Gui, Add, Button, x85 y%offset% w60 h28 Cancel, Cancel
		Gui, Add, Button, x150 y%offset% w150 h28 vswitchTemplate, Switch Template
		Gui, Font, S8, Arial
		offset := offset + 30
		Gui, Add, Button, x20 y%offset% w60 h28, Send Cassettes
		Gui, Add, Button, x85 y%offset% w60 h28, Send Slides

	SlideLabelPresets()

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
	Gui, Add, Text, x242 y70, P6 
	Gui, Add, Text, x292 y70, L1-3
	Gui, Add, Text, x342 y70, L1L2
	Gui, Add, Text, x392 y70, L1L2L3 
	PrinterChooser()

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
			Gui, Add, CheckBox, x172 y%offset% h28 v%A_Index%Split , Split?
			Gui, Add, CheckBox, x242 y%offset% h28 v%A_Index%P6
			Gui, Add, CheckBox, x292 y%offset% h28 v%A_Index%L1to3
			Gui, Add, CheckBox, x342 y%offset% h28 v%A_Index%L1L2 
			Gui, Add, CheckBox, x392 y%offset% h28 v%A_Index%L1L2L3 
			
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
			Gui, Add, CheckBox, x242 y%offset% h28 v%A_Index%P6
			Gui, Add, CheckBox, x292 y%offset% h28 v%A_Index%L1to3
			Gui, Add, CheckBox, x342 y%offset% h28 v%A_Index%L1L2 
			Gui, Add, CheckBox, x392 y%offset% h28 v%A_Index%L1L2L3 

			skipNext := false
		}
		
	}
		offset := offset + 50
		Gui, Add, Button, x20 y%offset% w60 h28 Default, Send
		Gui, Add, Button, x85 y%offset% w60 h28 Cancel, Cancel
		Gui, Add, Button, x150 y%offset% w150 h28 vswitchTemplate, Switch Template
		Gui, Font, S8, Arial
		offset := offset + 30
		Gui, Add, Button, x20 y%offset% w60 h28, Send Cassettes
		Gui, Add, Button, x85 y%offset% w60 h28, Send Slides

	SlideLabelPresets()

return
}

PrinterChooser()
{
	global
	Gui, Add, DropDownList, y5 x250 w270 Choose%UserPrinterDefault% gPrinterChange vPrinterChoice, 1: Zebra Lab ZM400 Histo|2: Zebra Lab ZM400 Left||3: Zebra Lab ZM400 Left2|4: Zebra Lab ZM400 Right
	return
}

PrinterChange:
{
	Gui, Submit, NoHide
	x := StrLen(PrinterChoice) - 3
	UserPrinterDefault := SubStr(PrinterChoice,1,1)
	selectedPrinter:=SubStr(PrinterChoice,4,x)
	;Msgbox, %selectedPrinter%,%UserPrinterDefault%
	return
}

BuildDeepersGUI()
{
	global
	Gui, Destroy
	Gui, Font, S12, Arial
	Gui, Add, Text, vcaseNumText, Case Number: %caseNum%
	Gui, Add, Text, vfullNameText ,%fullName%
	PrinterChooser()
	guiType := "Deepers"
	
	Gui, Add, Text, x22 y100, Block
	Gui, Add, Text, x112 y100, Level
	Gui, Add, Text, x172 y100, Stain
	Gui, Add, Edit, x22 y150 w50 h28 vBlock, %Block%
	Gui, Add, Edit, x112 y150 w50 h28 vLevel, %Level%
	Gui, Add, Edit, x172 y150 w50 h28 vStain, %Stain%
	Gui, Add, Text, x350 y50, %deeperStack%

	Gui, Add, Button, x20 y315 w60 h28 Default, Send
	Gui, Add, Button, x85 y315 w60 h28 Cancel, Cancel
	Gui, Add, Button, x150 y315 w150 h28 vstackLabel, Stack Label

return
}

ButtonStackLabel:
{
	Gui, Submit
	StringReplace, x, Stain, &, &&, All
	deeperStack=%deeperStack%%Block%;%Level%;%x%`n
	
	BuildDeepersGUI()
	Gui, Show, w500 h500,  %A_ScriptName% 
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
	if (guiType="US") {
		SendUSCassettes()
		SendUSSlides()
	} else if (guiType="Standard") {
		SendStandardCassettes()
		SendStandardSlides()
	} else if (guiType="Deepers")
		SendDeepersSlides()

	return
}

ButtonSendCassettes:
{
	Gui, Submit, NoHide
	if (guiType="US")
		SendUSCassettes()
	else if (guiType="Standard")
		SendStandardCassettes()

	return
}

ButtonSendSlides:
{
	Gui, Submit, NoHide
	if (guiType="US")
		SendUSSlides()
	else if (guiType="Standard")
		SendStandardSlides()
	
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
	url := ie.document.url
	caseNum := ie.document.getElementById("ctl00_DefaultContent_apcasedetail_Cases_ctl02_CaseNo").innerHTML
	;Msgbox, caseNum=%caseNum%
	If(caseNum="" OR InStr(url,Accessioning)=0)
	{
		Msgbox, "You must be on the 'Accessioning' page of a case to use this function."
		return
	}
	
	StringSplit, strspl, caseNum,-
	prefix := strspl1
	accessionNumber := SubStr(strspl2,2,5)
	leadingNumber := SubStr(accessionNumber, 1, 1)
	if (leadingNumber=0)
		accessionNumber :=SubStr(accessionNumber, 2,4)
	
	lastName := ie.document.getElementById("ctl00_DefaultContent_PatientUpdate_PatientLastNameValue").value
	firstName := ie.document.getElementById("ctl00_DefaultContent_PatientUpdate_PatientFirstNameValue").value
	clientNameSB := ie.document.getElementById("ctl00_DefaultContent_AccessionUpdate_ClientName")
	clientName := clientNameSB.options(clientNameSB.selectedIndex).text
	orderingPhysicianSB := ie.document.getElementById("ctl00_DefaultContent_AccessionUpdate_DoctorName")
	orderingPhysician := orderingPhysicianSB.options(orderingPhysicianSB.selectedIndex).text
	facilityNameSB := ie.document.getElementById("ctl00_DefaultContent_AccessionUpdate_FacilityName")
	facilityName := facilityNameSB.options(facilityNameSB.selectedIndex).text
	panelTypeSB := ie.document.getElementById("ctl00_DefaultContent_apcasedetail_Cases_ctl02_SpecimenDetail_PanelOrderAdd_PanelList")
	panelType := panelTypeSB.options(panelTypeSB.selectedIndex).text
	collectionDate := ie.document.getElementById("ctl00_DefaultContent_apcasedetail_Cases_ctl02_SpecimenDetail_Specimens_ctl02_ReceivedDateLabel").innerHTML

	Loop,
	{
		jarCount := A_Index -1
		i := indexToControlNumber(A_Index)
		jarID := "ctl00_DefaultContent_apcasedetail_Cases_ctl02_SpecimenDetail_Specimens_ctl" . i . "_ExternalSpecimenIDLabel"
		j := ie.document.getElementById(jarID).innerHTML
		StringLeft, p, j, 1
		if (p="")
			break
		jar%A_Index% := p
	}
	
	fullName := lastName . "," . firstName
	
	shortPrefix := GetShortPrefix(prefix)
	;Msgbox, shortPrefix=%shortPrefix%
	if (shortPrefix="US" or shortPrefix="TUS")
		BuildUSGUI()
	else if (shortPrefix="SP" or shortPrefix="TSP" or shortPrefix="GIS" or shortPrefix="GYS" or shortPrefix="BS")
		BuildStandardGUI()
	else
		BuildStandardGui()

	
	Gui, Show, ,  %A_ScriptName% 
	return
}

^F12::
{
	url := ie.document.url
	caseNum := ie.document.getElementById("ctl00_DefaultContent_CaseNoValue").innerHTML

	If(caseNum="" OR InStr(url,Case Status)=0)
	{
		Msgbox, "You must be on the 'Case Status' page of a specific case to use this function."
		return
	}

	StringSplit, strspl, caseNum,-
	prefix := strspl1
	accessionNumber := SubStr(strspl2,2,5)
	leadingNumber := SubStr(accessionNumber, 1, 1)
	if (leadingNumber=0)
		accessionNumber :=SubStr(accessionNumber, 2,4)
	fullName := ie.document.getElementById("ctl00_DefaultContent_PatientNameValue").innerHTML
	
	

	
	BuildDeepersGui()

	
	Gui, Show,w500 h500 ,  %A_ScriptName% 
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

SlideLabelPresets()
{
	global
	if (shortPrefix="US" or shortPrefix="TUS")
		varCode := "P6"
	else if (shortPrefix="SP" or shortPrefix="GIS")
		varCode := "L1to3"
	else if (shortPrefix="TSP" or shortPrefix="GYS" )
		varCode := "L1L2"
	else if (shortPrefix="BS")
		varCode := "L1L2L3"
	else
		varCode := "P6"
	
	;Msgbox, %jarcount% = jarcount
	Loop, %jarCount%
	{
		GuiControl, ,%A_Index%P6, 0
		GuiControl, ,%A_Index%L1to3, 0
		GuiControl, ,%A_Index%L1L2, 0
		GuiControl, ,%A_Index%L1L2L,  0
		GuiControl, ,%A_Index%%varCode%, 1
	}	

	return
}

SendStandardCassettes()
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

SendStandardSlides()
{
	global
	printdata := ""
	dataheader={"caseNum":"%caseNum%", "patientName":"%fullName%", "collectionDate":"%collectionDate%", "slides": [
	datafooter=]}
	labelCount := 1
	
	Loop, %jarCount%
	{
		jarLabel := jar%A_Index%
		jarQuantity := jar%A_Index%Quantity 
		jarNumber := A_Index
		
		if (jarQuantity=1) 
		{
			label%labelCount% := jarLabel
			labelJarNumber%labelCount% := jarNumber
			labelCount += 1
		} else 
		{
			Loop, %jarQuantity%
			{
				label%labelCount% =%jarLabel%%A_Index%
				labelJarNumber%labelCount% := jarNumber
				labelCount += 1
			}
		}
	}

		labelCount -= 1
		
		Loop, %labelCount%
		{
			thisLabel := label%A_Index%
			thisJarNumber := labelJarNumber%A_Index%
			
			;Msgbox, %thisLabel%,%thisJarNumber%
			
			if (%thisJarNumber%P6)
				thisData := codeP6(thisLabel)
			else if (%thisJarNumber%L1to3)
				thisData := codeL1to3(thisLabel)
			else if (%thisJarNumber%L1L2)
				thisData := codeL1L2(thisLabel)
			else if (%thisJarNumber%L1L2L3)
				thisData := codeL1L2L3(thisLabel)
			
			if (A_Index=labelCount)
				printdata=%printdata%%thisData%
			else 
				printdata=%printdata%%thisData%,
			
		}
		
			
		;Msgbox, %printdata%
		;return
	
	data=%dataheader%%printdata%%datafooter%
	PrintLabel(data)
	
	return
}

SendDeepersSlides()
{
	global
	printdata := ""
	dataheader={"caseNum":"%caseNum%", "patientName":"%fullName%", "collectionDate":"", "slides": [
	datafooter=]}
	
	StringReplace, deeperStack, deeperStack, &&, &, All
	Loop, Parse, deeperStack, `n
	{
		If (A_LoopField="")
			continue
		If (A_Index!=1)
			printdata=%printdata%,
		StringSplit, t, A_LoopField,;
		printdata=%printdata%["%t1%", "%t2%", "%t3%"]
	}
	data=%dataheader%%printdata%%datafooter%
	deeperStack := ""

	PrintLabel(data)
	return
}

codeP6(label)
{
	x=["%label%", "L1", "H&E"],["%label%", "L1x", "   "],["%label%", "L2", "H&E"],["%label%", "L2x", "   "],["%label%", "L3", "H&E"],["%label%", "L3x", "   "]
	return x
}

codeL1to3(label)
{
	x=["%label%", "L1-3", "H&E"]
	return x
}

codeL1L2(label)
{
	x=["%label%", "L1", "H&E"],["%label%", "L2", "H&E"]
	return x
}

codeL1L2L3(label)
{
	x=["%label%", "L1", "H&E"],["%label%", "L2", "H&E"],["%label%", "L3", "H&E"]
	return x
}

SendUSCassettes()
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
			if (jarQuantity>1)
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

SendUSSlides()
{
	global
	printdata := ""
	dataheader={"caseNum":"%caseNum%", "patientName":"%fullName%", "collectionDate":"%collectionDate%", "slides": [
	datafooter=]}
	labelCount := 1
	
	Loop, %jarCount%
	{
		
		thisKey := key%A_Index%
		if (thisKey="SKIP")
			continue
		else if(thisKey="LQ")
		{
			jarLabel := jar%A_Index%
			jarQuantity := %A_Index%Quantity 
			jarNumber := A_Index
			;Msgbox, %jarLabel%,%jarQuantity%
			
			if (jarQuantity=1) 
			{
				label%labelCount% := jarLabel
				labelJarNumber%labelCount% := jarNumber
				labelCount += 1
			} 
			else 
			{
				Loop, %jarQuantity%
				{
					label%labelCount% =%jarLabel%%A_Index%
					labelJarNumber%labelCount% := jarNumber
					labelCount += 1
				}
			}
		}
		else if(thisKey="PLS")
		{
			
			jarLabel := %A_Index%Label
			jarQuantity := jar%A_Index%Quantity 
			jarNumber := A_Index
			firstLetter := SubStr(%A_Index%Label,1,1)
			secondLetter := SubStr(%A_Index%Label,3,1)
			
			if (%A_Index%Print)
			{
				if (%A_Index%Split) 
				{
					label%labelCount% := firstLetter
					labelJarNumber%labelCount% := jarNumber
					labelCount += 1
					label%labelCount% := secondLetter
					labelJarNumber%labelCount% := jarNumber
					labelCount += 1
				}
				else
				{
					label%labelCount% := jarLabel
					labelJarNumber%labelCount% := jarNumber
					labelCount += 1
				}
			}
		}
	}

		labelCount -= 1
		
		Loop, %labelCount%
		{
			thisLabel := label%A_Index%
			thisJarNumber := labelJarNumber%A_Index%
			
			;Msgbox, %thisLabel%,%thisJarNumber%
			
			if (%thisJarNumber%P6)
				thisData := codeP6(thisLabel)
			else if (%thisJarNumber%L1to3)
				thisData := codeL1to3(thisLabel)
			else if (%thisJarNumber%L1L2)
				thisData := codeL1L2(thisLabel)
			else if (%thisJarNumber%L1L2L3)
				thisData := codeL1L2L3(thisLabel)
			
			if (A_Index=labelCount)
				printdata=%printdata%%thisData%
			else 
				printdata=%printdata%%thisData%,
			
		}
		
			
		;Msgbox, %printdata%
		;return
	
	data=%dataheader%%printdata%%datafooter%
	PrintLabel(data)	
	return

return
}

PrintLabel(labelData)
{
	global
	Msgbox, %data%  ;This is used to check the data before sending
	x := URLPost(slideQueue, labelData)
	key:=JsonToObject(x)
	key := key.name
	PrintPDFinLocalWindow(key)
	StringReplace, y, slideQueue,.json,,All
	y=%y%/%key%.json
	URLDelete(y)
	return
}

PrintPDFinLocalWindow(key)
{
	global
	Gosub, PrinterChange
	url=https://obscure-spire-2273.herokuapp.com/key/%key%
	URLDownloadToFile, https://obscure-spire-2273.herokuapp.com/key/%key%, %key%.pdf
	Loop,
	{
		IfExist, %key%.pdf
			break
		Sleep, 400
	}
	
	printerPath=\\adx-daldc02\%selectedPrinter%
	;Msgbox, %printerPath%
	
	Run, %AdobeReader% /t %key%.pdf %printerPath%
	WinWaitActive, %key%.pdf
		WinGetTitle, artitle, A
		StringReplace, artitle, artitle, %key%.pdf - ,,All
		StringTrimLeft, artitle, artitle, 1
	WinWaitClose, %key%.pdf
	
	Loop,
	{	
		;Msgbox, Trying to kill "%artitle%"
		WinKill, %artitle%
		IfWinExist, %artitle%
			Sleep, 300
		else
			break
	}
	FileDelete, %key%.pdf
	
	return
}

^!t::
{
	x := URLDownloadToVar("http://dazzling-torch-3393.firebaseio.com/SlidePrinting.json")
	y := JsonToObject(x)
	
	For key, value in y
		{
			FileDelete, %key%.pdf
			URLDownloadToFile, https://obscure-spire-2273.herokuapp.com/key/%key%, %key%.pdf
			c=https://dazzling-torch-3393.firebaseio.com/SlidePrinting/%key%.json
			URLDelete(c)
		}
	Sleep, 4000
	
	Loop N:\LNT\cassLink\*.pdf
	{
		RunWait, N:\LNT\lib\sumatra-pdf\SumatraPDF.exe -print-to-default  %A_LoopFileName% 
		FileDelete, %A_LoopFileName%
	}

	return
	
}

^!y::
{
	Msgbox, %artitle%
	return
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

ScrollLock::Suspend	
^!v::ListVars   ;List the variables currently in memory.
^!l::ListLines  ;List the most recently executed lines of code.
Pause::Pause
^!q::Reload
^!r::
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
