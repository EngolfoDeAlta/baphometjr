#Persistent
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

isRunning := false
state := "WaitingForPlayerPosition"
playerX := ""
playerY := ""
attackCheckCount := 0
noMonsterCount := 0
lastWalkDirection := ""

; Funções de comunicação com o servidor Python
SendToPython_MoveAndClick(x, y) {
    url := "http://127.0.0.1:8000/move_and_click?x=" x "&y=" y
    RunWait, %ComSpec% /c curl -s "%url%", , Hide
}

SendToPython_MoveOnly(x, y) {
    url := "http://127.0.0.1:8000/move_only?x=" x "&y=" y
    RunWait, %ComSpec% /c curl -s "%url%", , Hide
}

; GUI
Gui, +AlwaysOnTop +Resize
Gui, Add, Button, gStart vBtnStart w80, Start
Gui, Add, Button, gPause vBtnPause x+10 w80, Pause
Gui, Add, Edit, vLogBox w600 h300 ReadOnly xm y+10
Gui, Show, , Pixel Monitor

Log("Script loaded. Click 'Start' to begin.")
return

Start:
if (!isRunning) {
    isRunning := true
    Log("Monitoring started.")
    state := "WaitingForPlayerPosition"
    SetTimer, StateLoop, 400
} else {
    Log("Already running.")
}
return

Pause:
if (isRunning) {
    isRunning := false
    Log("Monitoring paused.")
    SetTimer, StateLoop, Off
    SetTimer, CheckAttack, Off
} else {
    Log("Already paused.")
}
return

StateLoop:
if (!isRunning)
    return



if (state = "WaitingForPlayerPosition") {
    MouseGetPos, playerX, playerY
    Log("Player position set: X=" . playerX . ", Y=" . playerY)
    state := "SearchingMonster"
    return
}

if (state = "SearchingMonster") {
    color1 := 0xE710FF
    color2 := 0x740880
    screenWidth := 1920
    screenHeight := 1080

    if (FindPixel(color1, x, y, screenWidth, screenHeight) || FindPixel(color2, x, y, screenWidth, screenHeight)) {
        Log("Monster found at " . x . "," . y)
        state := "Attacking"
        targetX := x
        targetY := y
        noMonsterCount := 0
    } else {
        Log("No monster found.")
        noMonsterCount++
        if (noMonsterCount >= 2) {
            Log("No monster found 3 times. Entering Walking state.")
            state := "Walking"
            noMonsterCount := 0
        }
    }
    return
}

if (state = "Attacking") {
    if (FindPixel(color1, x, y, screenWidth, screenHeight) || FindPixel(color2, x, y, screenWidth, screenHeight)) {
        Log("Will attack at " . x . "," . y)
        targetX := x
        targetY := y
        noMonsterCount := 0
    } else { 
        state := "SearchingMonster"
        return
    }
    if (attackCheckCount = 0) {
        Log("Attacking monster at " . targetX . "," . targetY)
        SendToPython_MoveAndClick(targetX + 10, targetY + 10)
        attackCheckCount := 1
        Sleep, 2000
        SetTimer, CheckAttack, 500
    }
    return
}

if (state = "CollectingLoot") {
    Log("Collecting loot...")

    Loop {
        if (!CollectLoot()) {
            Log("No more loot found.")
            break
        }
        Sleep, 1000
    }

    state := "SearchingMonster"
    return
}

if (state = "Walking") {
    Teleport()
    Sleep, 100
    state := "SearchingMonster"
    return
}

CheckAttack:
colorCheck1 := 0x000042
colorCheck2 := 0x000084
screenWidth := 1920
screenHeight := 1080

if (FindPixel(colorCheck1, dummyX, dummyY, screenWidth, screenHeight)
 || FindPixel(colorCheck2, dummyX, dummyY, screenWidth, screenHeight)) {
    Log("Still attacking, pixel found.")
    attackCheckCount := 1
} else {
    attackCheckCount++
    Log("No attack pixel found. Check count: " . attackCheckCount)
}

if (attackCheckCount >= 3) {
    Log("Attack seems finished. Searching area around player for loot...")
    SetTimer, CheckAttack, Off
    attackCheckCount := 0
    state := "CollectingLoot"
}
return

CollectLoot() {
    global state, isRunning
    lootColors := [0x21A300, 0x21A301, 0x22A502]
    screenWidth := 1920
    screenHeight := 1080

    Loop, 3 {
        color := lootColors[A_Index]
        if (FindPixel(color, lootX, lootY, screenWidth, screenHeight)) {
            Log("Loot pixel found at " . lootX . "," . lootY . " — clicking to interact.")
            SendToPython_MoveAndClick(lootX + 10, lootY + 10)
            return true
        }
    }
    return false
}

Teleport() {
    Log("Sending F4 key press to Python server.")
    url := "http://127.0.0.1:8000/press_key?key=f4"
    RunWait, %ComSpec% /c curl -s "%url%", , Hide
}

WalkRandomly() {
    global playerX, playerY, lastWalkDirection

    directions := ["a", "b", "c", "d"]
    loopCount := 0
    Random, randIndex, 1, 4
    selected := directions[randIndex]

    loop {
        if ((lastWalkDirection = "a" && selected = "d")
         || (lastWalkDirection = "d" && selected = "a")
         || (lastWalkDirection = "b" && selected = "c")
         || (lastWalkDirection = "c" && selected = "b")) {
            Random, randIndex, 1, 4
            selected := directions[randIndex]
            loopCount++
            if (loopCount > 10)
                break
        } else {
            break
        }
	Sleep, 400
    }

    lastWalkDirection := selected

    if (selected = "a") {
        walkX := playerX + 200
        walkY := playerY + 200
    } else if (selected = "b") {
        walkX := playerX - 200
        walkY := playerY + 200
    } else if (selected = "c") {
        walkX := playerX + 200
        walkY := playerY - 200
    } else if (selected = "d") {
        walkX := playerX - 200
        walkY := playerY - 200
    }

    Log("Walking in direction '" . selected . "' to X=" . walkX . ", Y=" . walkY)
    SendToPython_MoveAndClick(walkX, walkY)
}

FindPixel(color, ByRef foundX, ByRef foundY, width, height) {
    PixelSearch, foundX, foundY, 510, 270, width, height, color, 3, Fast RGB
    return !ErrorLevel
}

Log(text) {
    FormatTime, now,, HH:mm:ss
    GuiControlGet, currentLog,, LogBox
    lines := StrSplit(currentLog, "`n")

    lines.Push("[" . now . "] " . text)

    if (lines.MaxIndex() > 15)
        lines.RemoveAt(1, lines.MaxIndex() - 15)

    GuiControl,, LogBox, % Join("`n", lines*)
    GuiControl, Focus, LogBox
    Send, {End}
}

Join(delim, arr*) {
    str := ""
    Loop, % arr.MaxIndex()
    {
        str .= (A_Index = 1 ? "" : delim) . arr[A_Index]
    }
    return str
}

GuiClose:
ExitApp

; F9 alterna entre Start e Pause
F9::
if (isRunning) {
    Gosub, Pause
} else {
    Gosub, Start
}
return
