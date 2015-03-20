
F8::
{
x := URLDownloadToVar("http://dazzling-torch-3393.firebaseio.com/SlidePrinting.json")
Msbox, %x%
URLDownloadToFile, http://localhost:5000/next, sample.pdf
}

URLDownloadToVar(url){
	hObject:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	hObject.Open("GET",url)
	hObject.Send()
	return hObject.ResponseText
}