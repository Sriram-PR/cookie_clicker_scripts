#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Coordinates ---
preClickX := 2972
preClickY := 332
sellX := 2624
sellY := 320
mainClickX := 483
mainClickY := 748
buyX := 2624
buyY := 290
buildX := 2648
buildY := 700

; --- Timings (ms) ---
clickInterval := 10     ; main continuous click interval
gapInterval := 100      ; gap between buy/sell/build clicks
clickDuration := 11000  ; continuous clicking duration (11s)

; --- State ---
running := false
isClicking := false

; --- Hotkey: F2 to start/stop ---
F2::
{
    global running, preClickX, preClickY, gapInterval
    running := !running

    if running {
        Tooltip("Loop Started")

        ; Pre-click every time toggled ON
        Click(preClickX, preClickY)
        Sleep(gapInterval)

        StartCycle()
    } else {
        Tooltip("Loop Stopped")
        EmergencyStop()
    }
    SetTimer(ClearTooltip, -1000)
}

ClearTooltip()
{
    Tooltip()
}

; --- Emergency stop: stops immediately and clears timers ---
EmergencyStop()
{
    global running
    running := false
    StopClicking()
    SetTimer(StartCycle, 0)
    SetTimer(StopClicking, 0)
    SetTimer(BuyAndBuild, 0)
    SetTimer(MainClicker, 0)
}

; --- Start one cycle ---
StartCycle()
{
    global running, sellX, sellY, buildX, buildY, gapInterval, clickDuration

    if !running
        return

    Tooltip("Selling...")
    Click(sellX, sellY)
    Sleep(gapInterval)

    Tooltip("Building (pre-click)...")
    Click(buildX, buildY)
    Sleep(gapInterval)

    Tooltip("Main clicking...")
    StartClicking()

    ; Schedule stop of main clicking and Buy/Build after clickDuration
    SetTimer(StopClicking, -clickDuration)
    SetTimer(BuyAndBuild, -clickDuration)
}

; --- Buy + Build step ---
BuyAndBuild()
{
    global running, buyX, buyY, buildX, buildY, gapInterval

    if !running
        return

    Tooltip("Buying...")
    Click(buyX, buyY)
    Sleep(gapInterval)

    Tooltip("Building (post-buy)...")
    Click(buildX, buildY)
    Sleep(gapInterval)

    SetTimer(ClearTooltip, -800)

    if running
        SetTimer(StartCycle, -gapInterval)
}

; --- Continuous click functions ---
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
