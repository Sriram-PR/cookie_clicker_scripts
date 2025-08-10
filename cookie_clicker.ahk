#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Configuration ---
; Set the X and Y coordinates for the click location.
; To find coordinates, you can use the Window Spy tool included with AutoHotkey.
global ClickX := 483
global ClickY := 748

; Set the time between clicks in milliseconds.
global ClickInterval := 10 ;

; --- State Variable ---
; This variable tracks whether the auto-clicker is active.
global isClicking := false

; --- Hotkey Definition ---
; The tilde (~) prefix allows the F1 key's native function to pass through.
; If you don't want other windows to see you press F1, remove the tilde.
~F1::
{
    ; Explicitly declare the use of the global variable inside this function scope.
    global isClicking

    ; Toggle the state.
    isClicking := !isClicking

    if (isClicking)
    {
        ; When toggled ON, call the Clicker function immediately once,
        ; and then start the timer to call it repeatedly.
        Clicker()
        SetTimer(Clicker, ClickInterval)
        Tooltip("Auto-Clicker: ON", 0, 0) ; Optional: Show a status tooltip
    }
    else
    {
        ; When toggled OFF, disable the timer.
        SetTimer(Clicker, 0) ; Using 0 or "Off" disables the timer.
        Tooltip("Auto-Clicker: OFF", 0, 0) ; Optional: Show a status tooltip
    }
    ; Remove the tooltip after 1 second
    SetTimer(() => Tooltip(), -1000)
}

; --- Clicker Function ---
; This is the function that the timer will execute.
Clicker()
{
    ; Declare the global variables this function needs to access.
    global ClickX, ClickY

    ; Perform a single left-mouse click at the specified coordinates.
    Click(ClickX, ClickY)
}

; --- Exit Hotkey (Optional) ---
; Pressing Escape will terminate the script.
~Esc::
{
    ExitApp()
}
