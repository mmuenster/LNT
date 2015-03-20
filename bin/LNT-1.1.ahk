Startup:
{
#Include %A_ScriptDir%\LNT Internal Functions.ahk	
#Include %A_ScriptDir%\LNT External Functions.ahk
#SingleInstance force
#WinActivateForce
SendMode Input    
SetTitleMatchMode, 2
OnExit, ExitRoutine

Menu, SettingsMenu, Add, Etel Login Info, EtelLogin

Menu, UrovysionMenu, Add, Scan Cases to Review, UrovysionScanCases
Menu, UrovysionMenu, Add, Signout Pending Cases, UrovysionSignout

Menu, ExtendedPhrasesMenu, Add, Derm Extended Phrases, DermExtendedPhrases
Menu, ExtendedPhrasesMenu, Add, Grossing Extended Phrases, GrossingExtendedPhrases

Menu, MyMenuBar, Add, Urovysion, :UrovysionMenu
Menu, MyMenuBar, Add, Extended Phrases, :ExtendedPhrasesMenu
Menu, MyMenuBar, Add, Settings, :SettingsMenu
Gui, Menu, MyMenuBar

Gui, Add, Button, vButtonStartServer, Start Server
Gui, Add, Button, vButtonStopServer, Stop Server
Gui, Font, S12, Arial
Gui, Add, Text, vlblUsername ,Username:
Gui, Add, Text, vetelUsername, "                "
Gui, Show, W500 H500, "Lose No Time" - %A_ScriptName% 

urlBase=https://dazzling-torch-3393.firebaseio.com/AveroQueue
urlSettings=%urlBase%/Settings/%A_UserName%.json

userSettings := GetUserSettings(urlSettings)
if userSettings.DermExtendedPhrases=1
	Gosub, DermExtendedPhrases
if userSettings.GrossingExtendedPhrases=1
	Gosub, GrossingExtendedPhrases

Gosub, UpdateGuis
urlQueue := "https://dazzling-torch-3393.firebaseio.com/AveroQueue/" . userSettings.etelUsername . ".json"

if !userSettings
	FirstTimeSetup()

Progress, 0 x400 y1 h130, Preparing for first time use..., Written by Matthew Muenster M.D.`n`nInitializing..., CodeBuster 
Progress, 40, Reading personalized values...
Progress, 60, Getting the diagnosis codes from the database...
ReadDXCodes()
Progress, 80, Getting the helper codes from the database...
ReadHelpers()
CreateHelperListGui()
Progress, 100, Initialization complete!
Progress, Off




IfExist, %A_MyDocuments%\PersonalExtendedPhrases.ahk
	{
	Run, %A_ScriptDir%\Autohotkey.exe "%A_MyDocuments%\PersonalExtendedPhrases.ahk", ,UseErrorLevel , ppid	
	If ErrorLevel
		Msgbox, There was an error loading your personal extended phrases file.
	}
	

SetTimer, UpdateGuis, 3000 
return
}



UpdateGuis:
{
	GuiControl, ,etelUsername,% userSettings.etelUsername
	
	ifWinExist, ahk_pid %serverPID%
		{
			GuiControl, Hide, ButtonStartServer
			GuiControl, Show, ButtonStopServer
		}
	else
		{
			GuiControl, Show, ButtonStartServer
			GuiControl, Hide, ButtonStopServer
		}
	return
}

GuiClose:
{
	ExitApp
}

DermExtendedPhrases:
{
	if DermExtendedPhrases
	{
		Menu, ExtendedPhrasesMenu, Uncheck, Derm Extended Phrases
		DermExtendedPhrases := 0
		Process, Close, %epid%
	}
	Else
	{
		Menu, ExtendedPhrasesMenu, Check, Derm Extended Phrases
		DermExtendedPhrases := 1
		IfExist, %A_ScriptDir%\ExtendedPhrases.ahk
		{
			Run, %A_ScriptDir%\Autohotkey.exe "%A_ScriptDir%\ExtendedPhrases.ahk", ,UseErrorLevel , epid
			If ErrorLevel
				MsgBox, There was an error loading the corporate extended phrase file.
		}
	}
	return
}

GrossingExtendedPhrases:
{
	if GrossingExtendedPhrases
	{
		Menu, ExtendedPhrasesMenu, Uncheck, Grossing Extended Phrases
		GrossingExtendedPhrases := 0
	}
	Else
	{
		Menu, ExtendedPhrasesMenu, Check, Grossing Extended Phrases
		GrossingExtendedPhrases := 1
		IfExist, %A_ScriptDir%\GrossingExtendedPhrases.ahk
		{
			Run, %A_ScriptDir%\Autohotkey.exe "%A_ScriptDir%\GrossingExtendedPhrases.ahk", ,UseErrorLevel , gpid	
			If ErrorLevel
				Msgbox, There was an error loading your Grossing extended phrases file.
		}
	}
	return
}

ButtonStartServer:
{
	;global userSettings, serverPID
	p := userSettings.etelUsername
	q := userSettings.etelPassword 
	Run, "%A_ScriptDir%\etelmaster.bat" %p% %q% , , , serverPID
	Sleep, 500
	WinMinimize, cmd.exe
	Gosub, UpdateGuis
	return
}

ButtonStopServer:
{
	WinClose, ahk_pid %serverPID%
	WinWaitClose, ahk_pid %serverPID%
	Gosub, UpdateGuis
	return
}

EtelLogin:
{
	InputBox, etelUsername, Etel Username Entry, Enter the Etel Username to pass to the server...
	InputBox, etelPassword, Etel Password Entry, Enter the Etel Password to pass to the server..., Hide

	urlQueue= https://dazzling-torch-3393.firebaseio.com/AveroQueue/%etelUsername%.json
	t={"etelUsername":"%etelUserName%", "etelPassword":"%etelPassword%"}
	j := URLPatch(urlSettings, t)
	
	userSettings := GetUserSettings(urlSettings)
	Gosub, UpdateGuis
	return
}

JustReturn:
{
	return
}

UrovysionScanCases:  ;Urovysion Read Loop
{
	p := userSettings.etelUsername

	Loop,
	{
		InputBox, CaseNum, Scan the Urovysion case...,  Scan the case...	
		if ErrorLevel
			break
		else
		{
			Match1 := RegExMatch(CaseNum, "UV\d\d-\d\d\d\d\d\d")
			Match2 := RegExMatch(CaseNum, "US\d\d-\d\d\d\d\d\d")
			Match := Match1 + Match2
			
			if Match		
			{
				data={"action":"reassign", "caseNumber":"%CaseNum%", "doctor":"%p%" }
				j := URLPost(urlQueue, data)

				data={"action":"readUVCase", "caseNumber":"%CaseNum%" }
				j := URLPost(urlQueue, data)
			}
			else
			{
				SoundBeep
				Msgbox, %CaseNum% is not a valid Urovysion casenumber.
			}
		}
	}
	
	return
}

UrovysionSignout:
{
	Progress, x10 y10 h200, Preparing to signout, Obtaining Urovysion Cases for signout`n Press Ctrl-Alt-R to stop the signout, Working....,

	FileList =
	FileCount = 0
	FilePath := A_ScriptDir . "\temp\" . userSettings.etelUsername 

	Loop, %FilePath%\UV*.pdf , 1
		{
			FileList = %FileList%%A_LoopFileTimeModified%`t%A_LoopFileName%`n
			FileCount := FileCount + 1
		}
	Loop, %FilePath%\US*.pdf , 1
		{
			FileList = %FileList%%A_LoopFileTimeModified%`t%A_LoopFileName%`n
			FileCount := FileCount + 1
		}
	
	
	if (FileCount=0)
	{
		Progress, Off
		Msgbox, There are no UroVysion cases to signout.
		return
	}
	
	Sort, FileList  ; Sort by date.
	Progress, , Preparing to signout, Signing out the cases`n, Working....,

	Loop, parse, FileList, `n
		{
			if A_LoopField =  ; Omit the last linefeed (blank item) at the end of the list.
				continue
			y := FileCount - A_Index + 1
			x := 100 * (A_Index / FileCount)
			Progress, %x%,  %y% of %FileCount% cases remaining...`n  Press F3 to approve this case.`nPress F4 to skip this case.`nPress 'Delete' to skip signout and remove from queue`nPress 'End' to End signout loop.
			
			StringSplit, FileItem, A_LoopField, %A_Tab%  ; Split into two parts at the tab char.
			
			StringLeft, Drive, A_ScriptDir, 1
			
			Run, "%Drive%:/LNT/lib/sumatra-pdf/SumatraPDF.exe" %FilePath%\%FileItem2%
			Loop,
				{
					GetKeyState, F3state, F3
					GetKeyState, F4state, F4
					GetKeyState, EndState, End
					GetKeyState, BackspaceState, BackSpace
					GetKeyState, DeleteState, Delete
					If F3state=D
					{
						StringSplit, output, FileItem2, .
						LISQueueSignout(output1)
						FileDelete, %FilePath%\%FileItem2%
						WinClose, %FileItem2%
						Sleep, 50
						Break
					}
					else If F4state=D
					{
						;Delete PDF File and or LISDeletePDFReviewAction(v.nodeName)
						WinClose, %FileItem2%
						sleep, 50
						Break
					}
					else If Endstate=D
					{
						Progress, Off
						WinClose, %FileItem2%
						Return
					}
					else if DeleteState=D
					{
						FileDelete, %FilePath%\%FileItem2%
						WinClose, %FileItem2%
						Sleep, 50
						break
					}
					else if BackspaceState=D
					{

						Inputbox, action, CPT Code Modify, Enter the code modify statement...
						StringSplit, actions, action, %A_Space%
						codeline:=""
							
						Loop, %actions0%
						{
							code := actions%A_Index%

							
							if (code="5")
								codeline=%codeline% 88305-G:
							else if (code="4") 
								codeline=%codeline% 88304-G:
							else if (code="12")
								codeline=%codeline% 88312-G:
							else if (code="42")
								codeline=%codeline% 88342-G:
							else if (code="5")
								FileAppend, add312`n, %A_ScriptDir%\temp\-cptEdits~%dacasenum1%.txt
							else if (code="5")
								FileAppend, del312`n, %A_ScriptDir%\temp\-cptEdits~%dacasenum1%.txt
							else if (code="5")
								FileAppend, add342`n, %A_ScriptDir%\temp\-cptEdits~%dacasenum1%.txt
							else if (code="5")
								FileAppend, del342`n, %A_ScriptDir%\temp\-cptEdits~%dacasenum1%.txt
														
						}
					Msgbox,4,, Are the following codes correct?`n %codeline%				
					IfMsgBox, No
						Continue ; User pressed the "No" button.
					IfMsgbox, Yes
					{
						LISQueueCPTEditsAndResave(v.caseNumber, codeline, true)
						LISDeletePDFReviewAction(v.nodeName)

						break
					}

					}
				}

		}

	Progress, Off
	
	Return

}

ExitRoutine:
{
	Process, Close, %epid%
	Process, Close, %ppid%
	Process, Close, %gpid%

	WinClose, ahk_pid %serverPID%
	WinWaitClose, ahk_pid %serverPID%

	ExitApp
}

#IfWinActive     ;Resets #IfWin directive so that hotkeys can be turned off

F9::  ;Show all helpers
{
Gui, 3:Font, 
Gui, 3:show, ,List of Available Helpers
Return
}

F12::   ;Etel Reassign and Launch functions
{
	InputBox, CaseNum, , Please enter the case number to autoassign., , 200, 200
	
	j = https://path.averodx.com/Custom/Avero/Workflow/CaseStatus.aspx?CaseNo=%CaseNum%

	ie.Navigate(j)
	IELoad(ie)
	
	j := ie.document.getElementByID["ctl00_DefaultContent_assignCase2User_AssignedUser"]
	j.click()

	Loop,
	{
		Sleep, 100
		j := ie.document.getElementByID["ctl00_DefaultContent_assignCase2User_saveAssignedUser"].clientHeight
		if j>0
			break
	}
	if (A_Username="mmuenster")
		docvalue := "101773"
	else if (A_Username="tmattison")
		docvalue := "100376"
	else if (A_Username="tlmattison")
		docvalue := "100375"
	else if (A_Username="trmattison")
		docvalue := "100377"
	else if (A_Username="dhull")
		docvalue := "101637"
	else if (A_Username="tlamm")
		docvalue := "101772"
	else if (A_Username="jhurrell")
		docvalue := "101440"
	else if (A_Username = "rstuart")
		docvalue := "100435"
	else if (A_Username = "aeastman")
		docvalue := "100437"
	else if (A_Username = "ekiss")
		docvalue := "101759"
	

	j := ie.document.getElementByID["ctl00_DefaultContent_assignCase2User_drpAssignedUser"]
	j.value := docvalue
	ie.document.getElementByID["ctl00_DefaultContent_assignCase2User_saveAssignedUser"].click()

	Loop,
	{
		Sleep, 100
		j := ie.document.getElementByID["ctl00_DefaultContent_assignCase2User_saveAssignedUser"].clientHeight
		if (j="")
			break
	}

	ie.document.getElementByID["ctl00_DefaultContent_Launch"].click()
	IELoad(ie)

	return
}

^!t::  ;code transfer helper
{
	InputBox, code, Code to transfer..., Which code to you want to transfer
	url=https://dazzling-torch-3393.firebaseio.com/diagnosisCodes/%code%.json
	t := UrlDownloadToVar(url)
	t={"%code%":%t%}
	url=https://dazzling-torch-3393.firebaseio.com/newDiagnosisCodes.json
	j := URLPatch(url, t)


	Return
}

^!o::    ;Photo taking loop
{
	Loop,
	{
	WinActivate, cellSens
	WinWaitActive, cellSens
	
	InputBox, casenum, Scan the case number...
	if ErrorLevel
		Break
	else
		{
		ControlClick,  Button32, cellSens  ;Click the live button to turn on
		Msgbox, 4,  Close when picture is ready to take.
		IfMsgBox Yes
			Sleep, 5
		else
			{
			ControlClick,  Button32, cellSens  ;Click the live button to turn off
			Continue
		}
		ControlClick, Button34, cellSens  ;Click the Snapshot button
		Sleep, 1000
		WinActivate, cellSens
		WinWaitActive, cellSens
		Send, {Ctrl Down}S{Ctrl Up}
		WinWaitActive, Save Image As
		Send, %casenum%
	
		Send, {Enter}
		
		
		Sleep, 1000
		
		FileMove, C:\Users\mmuenster\Desktop\Temp Photos\%casenum%.jpg, I:\%casenum%.jpg
		
		p := userSettings.etelUsername
		;Queue Reassign
		data={"action":"reassign", "caseNumber":"%casenum%", "doctor":"%p%" }
		j := URLPost(urlQueue, data)

		;Queue DataRead
		data={"action":"readCase", "caseNumber":"%casenum%", "doctor":"%p%" }
		j := URLPost(urlQueue, data)
		
		Continue
		}
	}

	Return
}

^!p::
{
	p := userSettings.etelUsername
	
	Loop,
	{
		InputBox, CaseNum, Scan the case...,  Scan the case...	
		if ErrorLevel
			break
		else
		{
			data={"action":"reassign", "caseNumber":"%CaseNum%", "doctor":"%p%" }
			j := URLPost(urlQueue, data)
			
			data={"action":"readCase", "caseNumber":"%CaseNum%" }
			j := URLPost(urlQueue, data)
		}
	}
	
	return

}

^!d::
{
	urlQueue = https://dazzling-torch-3393.firebaseio.com/CaseData.json?limitToFirst=1&orderBy="$key"

j := URLDownloadToVar(urlQueue)

if (j="{}")
	Return

t := JsonToObject(j)

For k,v in t
	key:=k	

urlToDelete=https://dazzling-torch-3393.firebaseio.com/CaseData/%key%.json
URLDelete(urlToDelete)
return
}

^!z::
{
Loop,
	{
		InputBox, CaseNum, Scan the case...,  Scan the case...	
		if ErrorLevel
			break
		else
		{
			Match := RegExMatch(CaseNum, "UV\d\d-\d\d\d\d\d\d")
			Msgbox, %Match%

		}
	}
	
	return
}

^!1::  ;Move all extended phrases from the database to the "hotstring" file.
{   
	;Dropbox cannot be written to this quickly.  Had to modify to write to local drive then copy to Dropbox Folder
	FileDelete, %A_MyDocuments%\ExtendedPhrases.ahk
	FileDelete, %A_ScriptDir%\_xtendedPhrases.ahk
	FileMove, %A_ScriptDir%\ExtendedPhrases.ahk, %A_ScriptDir%\_xtendedPhrases.ahk
	FileAppend, #NoTrayIcon`n#SingleInstance force`n#Hotstring EndChars  ``t`n,%A_MyDocuments%\ExtendedPhrases.ahk
	t := UrlDownloadToVar("https://dazzling-torch-3393.firebaseio.com/extendedPhrases.json")
	fh := JsonToObject(t)
	
	For k, v in fh
		{
        FileAppend, ::%k%::%v%`n,%A_MyDocuments%\ExtendedPhrases.ahk
        If ErrorLevel
            Msgbox, ERROR`nk=%k%`nv=%v%
    }
	
	FileMove, %A_MyDocuments%\ExtendedPhrases.ahk, %A_ScriptDir%\ExtendedPhrases.ahk

	Msgbox, Extended Phrase Import Complete!
	return
}

^!2::  ;Move all grossing phrases from the database to the grossing "hotstring" file.
{   
	;Dropbox cannot be written to this quickly.  Had to modify to write to local drive then copy to Dropbox Folder
	FileDelete, %A_MyDocuments%\GrossingExtendedPhrases.ahk
	FileDelete, %A_ScriptDir%\_rossingExtendedPhrases.ahk
	FileMove, %A_ScriptDir%\GrossingExtendedPhrases.ahk, %A_ScriptDir%\_rossingExtendedPhrases.ahk
	FileAppend, #NoTrayIcon`n#SingleInstance force`n#Hotstring EndChars  ``t`n,%A_MyDocuments%\GrossingExtendedPhrases.ahk
	t := UrlDownloadToVar("https://dazzling-torch-3393.firebaseio.com/grossingCodes.json")
	fh := JsonToObject(t)
	
	For k, v in fh
		{
        FileAppend, ::%k%::%v%`n,%A_MyDocuments%\GrossingExtendedPhrases.ahk
        If ErrorLevel
            Msgbox, ERROR`nk=%k%`nv=%v%
    }
	
	FileMove, %A_MyDocuments%\GrossingExtendedPhrases.ahk, %A_ScriptDir%\GrossingExtendedPhrases.ahk

	Msgbox,Grossing Extended Phrase Import Complete!
	return
}

ScrollLock::Suspend	
^!v::ListVars   ;List the variables currently in memory.
^!l::ListLines  ;List the most recently executed lines of code.
Pause::Pause
^!r::
{
	PossibleDrives=ZYXWVUTSRQPONMLKJIHGFE

version:=URLDownloadToVar("https://dazzling-torch-3393.firebaseio.com/AveroQueue/Settings/version.json")
StringReplace, version, version, ",,All

Loop, Parse, PossibleDrives
	IfExist, %A_LoopField%:\LNT\bin\LNT-%version%.ahk
	{
		Run, %A_LoopField%:\LNT\lib\Autohotkey\Autohotkey.exe %A_LoopField%:\LNT\bin\LNT-%version%.ahk
		break
	}
return
}

