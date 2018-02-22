Set Args = Wscript.Arguments
For Each arg In args
	strString = arg
	strHex =""
	For i=1 To Len(strString)
	    strHex = strHex + Hex(Asc(Mid(strString,i,1)))
	Next

	WScript.Echo strHex
Next