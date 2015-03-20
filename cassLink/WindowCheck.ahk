
	candidate := ""
	
	For pwb in ComObjCreate( "Shell.Application" ).Windows
{
      	s := pwb.FullName
	Msgbox, %s%
	If InStr( pwb.FullName, "iexplore.exe" )
		If Instr( pwb.Document.url, "path.averodx.com")
			if (pwb.Visible = -1)   ;Returns -1 when visible, 0 when hidden
				{
				candidate := pwb
				if (pwb.getProperty("WinNum") = 1)
					j := pwb
				}
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
			Return 
		}
