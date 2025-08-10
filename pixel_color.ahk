#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Default coordinates ---
coordX := 2710
coordY := 790

; F1: Show pixel color at the coordinates
F1::
{
    global coordX, coordY

    color := PixelGetColor(coordX, coordY, "RGB")
    hexColor := Format("{:06X}", color & 0xFFFFFF) ; convert to hex string

    MsgBox("Pixel color at (" coordX ", " coordY ") = #" hexColor, "Pixel Color")
}
