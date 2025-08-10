#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Coordinates ---
coords := Map(
    "noResearch", { buyX: 2630, buyY: 290, sellX: 2630, sellY: 320, buildX: 2630, buildY: 660, toggleX: 2990, toggleY: 310 },
    "withResearch", { buyX: 2630, buyY: 440, sellX: 2630, sellY: 470, buildX: 2630, buildY: 810, toggleX: 2990, toggleY: 460 }
)
mainClickX := 480
mainClickY := 740

; --- Timings (ms) ---
clickInterval := 10      ; cookie click interval
gapInterval := 100       ; gap between actions
clickDuration := 10000   ; cookie clicking duration (10s)

; --- State ---
running := false
isClicking := false
mode := "" ; "noResearch" or "withResearch"

; --- Hotkeys to start/stop ---
F2::ToggleLoop("noResearch")
F3::ToggleLoop("withResearch")

ToggleLoop(selectedMode)
{
    global running, mode
    running := !running
    mode := selectedMode

    if running {
        Tooltip("Loop Started: " . mode)
        StartCycle()
    } else {
        Tooltip("Loop Stopped")
        EmergencyStop()
    }
    SetTimer(ClearTooltip, -1000)
}

ClearTooltip() => Tooltip()

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

; --- One cycle ---
StartCycle()
{
    global running, coords, mode, gapInterval, clickDuration

    if !running
        return

    ; Sell (normal click)
    Tooltip("Selling...")
    Click(coords[mode].sellX, coords[mode].sellY)
    Sleep(gapInterval)

    ; Pre-Build (toggle click then build)
    Tooltip("Pre-Build...")
    Click(coords[mode].toggleX, coords[mode].toggleY)
    Sleep(30) ; tiny pause to ensure the toggle click registers
    Click(coords[mode].buildX, coords[mode].buildY)
    Sleep(gapInterval)

    ; Cookie clicking
    Tooltip("Main clicking...")
    StartClicking()

    ; Schedule stop and buy/build
    SetTimer(StopClicking, -clickDuration)
    SetTimer(BuyAndBuild, -clickDuration)
}

; --- Buy + Build ---
BuyAndBuild()
{
    global running, coords, mode, gapInterval

    if !running
        return

    ; Buy (normal click)
    Tooltip("Buying...")
    Click(coords[mode].buyX, coords[mode].buyY)
    Sleep(gapInterval)

    ; Post-Build (toggle click then build)
    Tooltip("Post-Build...")
    Click(coords[mode].toggleX, coords[mode].toggleY)
    Sleep(30)
    Click(coords[mode].buildX, coords[mode].buildY)
    Sleep(gapInterval)

    SetTimer(ClearTooltip, -800)

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
