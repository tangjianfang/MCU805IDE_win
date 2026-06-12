' lf2crlf.vbs - Convert a text file from LF to CRLF line endings
' Usage: cscript //nologo lf2crlf.vbs <input> <output>
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.OpenTextFile(WScript.Arguments(0), 1)
Set g = fso.CreateTextFile(WScript.Arguments(1), True)
Do Until f.AtEndOfStream
    s = f.ReadLine
    g.WriteLine s
Loop
f.Close
g.Close
