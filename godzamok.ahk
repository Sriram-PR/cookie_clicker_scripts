#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Coordinates ---
coords := Map(
    "noResearch",  { buyX: 2630, buyY: 290, sellX: 2630, sellY: 320, buildX: 2630, buildY: 660, toggleX: 2990, toggleY: 310 },
    "withResearch",{ buyX: 2630, buyY: 440, sellX: 2630, sellY: 470, buildX: 2630, buildY: 810, toggleX: 2990, toggleY: 460 }
)
mainClickX := 480
mainClickY := 740

; --- Timings (ms) ---
clickInterval := 10       ; cookie click interval
gapInterval := 50        ; gap between actions
clickDuration := 5250 + 50   ; cookie clicking duration (10s)
toggleDelay := 25         ; small delay between toggle click and build click
tooltipDuration := 1000    ; how long tooltips stay visible (ms)

; --- State ---
running := false
isClicking := false
mode := "" ; "noResearch" or "withResearch"

; --- Hotkeys to start/stop ---
F2::ToggleLoop("noResearch")
F3::ToggleLoop("withResearch")

lastToggle := 0
minRunTime := 1000  ; minimum time (ms) the loop must run before stopping allowed
startTime := 0

ToggleLoop(selectedMode)
{
    static debounce := 300  ; ms between toggles allowed
    global running, mode, lastToggle, startTime, minRunTime

    currentTime := A_TickCount

    ; Ignore toggles that happen too fast after the previous one (debounce)
    if (currentTime - lastToggle < debounce)
        return

    lastToggle := currentTime

    if !running
    {
        ; Start the loop
        running := true
        mode := selectedMode
        startTime := currentTime
        ShowTip("Loop Started: " . mode, 1000)
        StartCycle()
    }
    else
    {
        ; If minimum runtime not elapsed, ignore stop
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
    ; clear timers
    SetTimer(StartCycle, 0)
    SetTimer(StopClicking, 0)
    SetTimer(BuyAndBuild, 0)
    SetTimer(MainClicker, 0)
}

; --- Toggle + Build helper ---
ToggleAndBuild(mode)
{
    global coords, gapInterval, toggleDelay
    Click(coords[mode].toggleX, coords[mode].toggleY)
    Sleep(toggleDelay)
    Click(coords[mode].buildX, coords[mode].buildY)
    Sleep(gapInterval)
}

; --- Config ---
buffCycles := 19  ; number of sell/build/buy/build loops before main click

; --- Main cycle with buff stacking ---
StartCycle()
{
    global running, coords, mode, gapInterval, clickDuration, buffCycles

    if !running
        return

    ; --- Buff stacking phase ---
    Loop buffCycles
    {
        ShowTip("Buff cycle " . A_Index . " / " . buffCycles)

        ; Sell
        Click(coords[mode].sellX, coords[mode].sellY)
        Sleep(gapInterval)

        ; Pre-Build
        Click(coords[mode].toggleX, coords[mode].toggleY)
        Sleep(25) ; toggleDelay
        Click(coords[mode].buildX, coords[mode].buildY)
        Sleep(gapInterval)

        ; Buy
        Click(coords[mode].buyX, coords[mode].buyY)
        Sleep(gapInterval)

        ; Post-Build
        Click(coords[mode].toggleX, coords[mode].toggleY)
        Sleep(25)
        Click(coords[mode].buildX, coords[mode].buildY)
        Sleep(gapInterval)
    }

    ; --- Main click phase ---
    ShowTip("Main clicking...")
    StartClicking()

    ; Schedule stop and restart cycle
    SetTimer(StopClicking, -clickDuration)
    SetTimer(StartCycle, -clickDuration)
}

; --- Buy + Build ---
BuyAndBuild()
{
    global running, coords, mode, gapInterval

    if !running
        return

    ; Buy
    ShowTip("Buying...")
    Click(coords[mode].buyX, coords[mode].buyY)
    Sleep(gapInterval)

    ; Post-Build
    ShowTip("Post-Build...")
    ToggleAndBuild(mode)

    if running
        SetTimer(StartCycle, -gapInterval)
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