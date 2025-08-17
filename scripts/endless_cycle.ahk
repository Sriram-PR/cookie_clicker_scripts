#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Mouse", "Client" ; use client (window) coordinates

; ----- CONFIG (coords & timings) -----
reincarnate := [1630, 200]
toggle := [2990, 510]
b1 := [2900, 600]
b2 := [2900, 730]
b3 := [2900, 850]
b4 := [2900, 970]
upgrade := [2900, 290]
ascend := [2430, 140]

gap100 := 100
gap250 := 250
gap500 := 500
gap2000 := 2000

; ----- STATE -----
running := false
step := 1
b_iter := 1
b_sub := 1
nextTime := 0

; ----- HOTKEY: toggle start/stop -----
#HotIf WinActive("ahk_exe Cookie Clicker.exe")
F1::
{
    global running, step, b_iter, b_sub, nextTime
    running := !running
    if running {
        step := 1
        b_iter := 1
        b_sub := 1
        nextTime := A_TickCount
        SetTimer Worker, 10
        ToolTip "Cookie Auto: RUNNING`nPress F1 to stop"
    } else {
        SetTimer Worker, 0
        ToolTip "Cookie Auto: STOPPED"
        Sleep 800
        ToolTip
    }
}
#HotIf

; ----- MAIN WORKER -----
Worker() {
    global running, step, b_iter, b_sub, nextTime
    if !running
        return
    if !WinActive("ahk_exe Cookie Clicker.exe")
        return
    if (A_TickCount < nextTime)
        return

    switch step {
        case 1: ; reincarnate
            Click reincarnate[1], reincarnate[2]
            nextTime := A_TickCount + gap100
            step := 2
        case 2: ; Enter
            Send "{Enter}"
            nextTime := A_TickCount + gap2000
            step := 3
        case 3: ; toggle
            Click toggle[1], toggle[2]
            nextTime := A_TickCount + gap100
            step := 4
            b_iter := 1
            b_sub := 1
        case 4: ; b_loop sequence
            coords := [b1, b2, b3, b4, upgrade]
            Click coords[b_sub][1], coords[b_sub][2]
            Click coords[b_sub][1], coords[b_sub][2]
            nextTime := A_TickCount + gap500
            b_sub++
            if (b_sub > 5) {
                b_sub := 1
                b_iter++
                if (b_iter > 5) {
                    step := 5
                }
            }
        case 5: ; gap before ascend
            nextTime := A_TickCount + gap100
            step := 6
        case 6: ; ascend
            Click ascend[1], ascend[2]
            nextTime := A_TickCount + gap100
            step := 7
        case 7: ; Enter after ascend
            Send "{Enter}"
            nextTime := A_TickCount + gap100
            step := 8
        case 8: ; Esc then loop
            Send "{Esc}"
            nextTime := A_TickCount + gap500
            step := 1
    }
}