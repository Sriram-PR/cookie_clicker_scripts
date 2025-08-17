#Requires AutoHotkey v2.0
#SingleInstance Force

coords := {
    buyX: 2630, buyY: 490,
    sellX: 2630, sellY: 520,
    builds: [
        { x: 2630, y: 860 },
        { x: 2630, y: 980 },
        { x: 2630, y: 1100 },
        { x: 2630, y: 1220 }
    ]
}
mainClickX := 480
mainClickY := 740

; --- Timings (ms) ---
clickInterval := 10          ; cookie click interval
gapInterval := 50            ; gap between actions
cycleRepeats := 5            ; how many times to repeat sell → 4 builds → buy → 4 builds
clickDuration := 7500        ; main clicking duration so full loop = 10s
loopDuration := 7600        ; total loop length (ms)
tooltipDuration := 1000      ; tooltip visibility time (ms)

; --- State ---
running := false
isClicking := false
inCyclePhase := false

; --- Hotkey ---
F3::ToggleLoop()

lastToggle := 0
minRunTime := 1000  ; minimum ms before allowing stop
startTime := 0

ToggleLoop()
{
    static debounce := 300
    global running, lastToggle, startTime, minRunTime, inCyclePhase

    currentTime := A_TickCount

    if (currentTime - lastToggle < debounce)
        return
    lastToggle := currentTime

    ; Prevent stop/start during critical phase
    if inCyclePhase
    {
        ShowTip("Busy: Wait until build/sell/buy phase ends", 1000)
        return
    }

    if !running
    {
        running := true
        startTime := currentTime
        ShowTip("Loop Started", 1000)
        StartCycle()
    }
    else
    {
        if (currentTime - startTime < minRunTime)
            return
        running := false
        ShowTip("Loop Stopped", 1000)
        EmergencyStop()
    }
}

; --- Tooltip helper ---
ShowTip(text, duration := 800)
{
    Tooltip(text)
    SetTimer(() => Tooltip(), -duration)
}

; --- Emergency stop ---
EmergencyStop()
{
    global running
    running := false
    StopClicking()
    SetTimer(StartCycle, 0)
    SetTimer(StopClicking, 0)
    SetTimer(MainClicker, 0)
}

; --- Main cycle ---
StartCycle()
{
    global running, coords, gapInterval, clickDuration, cycleRepeats, loopDuration, inCyclePhase

    if !running
        return

    inCyclePhase := true   ; lock here

    Loop cycleRepeats
    {
        ShowTip("Cycle " . A_Index . " / " . cycleRepeats)

        ; Sell
        Click(coords.sellX, coords.sellY)
        Sleep(gapInterval)

        ; 4 Builds
        For build in coords.builds
        {
            Click(build.x, build.y)
            Sleep(gapInterval)
        }

        ; Buy
        Click(coords.buyX, coords.buyY)
        Sleep(gapInterval)

        ; 4 Builds again
        For build in coords.builds
        {
            Click(build.x, build.y)
            Sleep(gapInterval)
        }
    }

    inCyclePhase := false  ; unlock before clicking starts

    ; Main clicking phase
    ShowTip("Main clicking...")
    StartClicking()

    SetTimer(StopClicking, -clickDuration)
    SetTimer(StartCycle, -loopDuration)
}

; --- Continuous click ---
StartClicking()
{
    global isClicking, clickInterval
    if !isClicking {
        isClicking := true
        SetTimer(MainClicker, clickInterval)
    }
}

StopClicking()
{
    global isClicking
    if isClicking {
        isClicking := false
        SetTimer(MainClicker, 0)
    }
}

MainClicker()
{
    global mainClickX, mainClickY, isClicking
    if !isClicking
        return
    Click(mainClickX, mainClickY)
}

; --- Exit ---
Esc::ExitApp()
