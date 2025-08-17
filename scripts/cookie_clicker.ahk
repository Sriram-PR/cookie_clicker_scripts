#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Configuration ---
; Click coordinates
global ClickX := 480
global ClickY := 740

; Time between clicks in milliseconds
global ClickInterval := 10

; Duration to run in seconds (0 = run indefinitely)
global RunDuration := 0  ; Change to 0 for infinite

; --- State Variables ---
global isClicking := false
global stopTimerId := ""  ; For tracking the stop timer

; --- Hotkey ---
~F1::
{
    global isClicking, stopTimerId, RunDuration

    isClicking := !isClicking

    if (isClicking)
    {
        Clicker()
        SetTimer(Clicker, ClickInterval)
        Tooltip("Auto-Clicker: ON", 0, 0)

        ; Start auto-stop timer if duration > 0
        if (RunDuration > 0)
        {
            stopTimerId := SetTimer(StopClicker, -RunDuration * 1000)
        }
    }
    else
    {
        StopClicker()
    }

    SetTimer(() => Tooltip(), -1000)
}

; --- Stop Function ---
StopClicker()
{
    global isClicking
    isClicking := false
    SetTimer(Clicker, 0)
    Tooltip("Auto-Clicker: OFF", 0, 0)
    SetTimer(() => Tooltip(), -1000)
}

; --- Clicker Function ---
Clicker()
{
    global ClickX, ClickY
    Click(ClickX, ClickY)
}

; --- Exit Hotkey ---
~Esc::
{
    ExitApp()
}