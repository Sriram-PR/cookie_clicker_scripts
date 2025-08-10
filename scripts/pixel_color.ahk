#Requires AutoHotkey v2.0
#SingleInstance Force

running := false

F1::  ; Toggle start/stop
{
    global running
    running := !running

    if running {
        SetTimer(ShowCursorPixelColor, 50) ; update every 50 ms
    } else {
        SetTimer(ShowCursorPixelColor, 0)
        Tooltip() ; clear tooltip
    }
}

ShowCursorPixelColor()
{
    MouseGetPos &mx, &my
    color := PixelGetColor(mx, my, "RGB")
    hexColor := Format("{:06X}", color & 0xFFFFFF)
    Tooltip("Pos: (" mx ", " my ") | Color: #" hexColor)
}
