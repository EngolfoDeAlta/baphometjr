#Persistent
CoordMode, Pixel, Screen
isRunning := false

; GUI
Gui, +AlwaysOnTop +Resize
Gui, Add, Edit, vLogBox w500 h300 ReadOnly
Gui, Show, , Teleport

; Atalho F10 para iniciar/pausar
F10::
isRunning := !isRunning
if (isRunning) {
    Log("Script iniciado.")
    SetTimer, MainRoutine, 300000
} else {
    Log("Script pausado.")
    SetTimer, MainRoutine, Off
}
return

MainRoutine:
{
	Teleport()
}
return

Teleport() {
    Log("Sending F4 key press to Python server.")
    url := "http://127.0.0.1:8000/press_key?key=f4"
    RunWait, %ComSpec% /c curl -s "%url%", , Hide
}

Log(text) {
    FormatTime, now,, HH:mm:ss
    GuiControlGet, currentLog,, LogBox
    lines := StrSplit(currentLog, "`n")
    lines.Push("[" . now . "] " . text)

    if (lines.MaxIndex() > 20)
        lines.RemoveAt(1, lines.MaxIndex() - 20)

    GuiControl,, LogBox, % Join("`n", lines*)
    GuiControl, Focus, LogBox
    Send, {End}
}

Join(delim, arr*) {
    str := ""
    Loop, % arr.MaxIndex()
        str .= (A_Index = 1 ? "" : delim) . arr[A_Index]
    return str
}

GuiClose:
ExitApp

