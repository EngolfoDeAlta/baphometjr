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
    SetTimer, MainRoutine, 180000          ; A cada 3 minutos (f4)
    SetTimer, F6Routine, 2400000           ; A cada 40 minutos (f6)
    SetTimer, F7Routine, 1800000           ; A cada 30 minutos (f7)
} else {
    Log("Script pausado.")
    SetTimer, MainRoutine, Off
    SetTimer, F6Routine, Off
}
return

MainRoutine:
{
    Teleport("f4")
}
return

F6Routine:
{
    Teleport("f6")
}
return

F7Routine:
{
    Teleport("f7")
}
return

Teleport(key) {
    Log("Enviando tecla " . key . " para servidor Python.")
    url := "http://127.0.0.1:8000/press_key?key=" . key
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
