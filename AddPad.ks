Parameter cName is "", cLat is 999999, cLng is 999999.
Set Done to False. Set Exit to False.
If cName = "Current" {
  Log "cPads:Add(" + Char(34) + Ship:Name + Char(34) + ")." to "Pads". Log "cPads:Add(" + Char(34) + Ship:GeoPosition:Lat + ", " + Ship:GeoPosition:Lng + Char(34) + ")." to "Pads".
} Else If cName = "Target" {
  If HasTarget = True and Target:Body:Name = Body:Name { Log "cPads:Add(" + Char(34) + Target:Name + Char(34) + ")." to "Pads". Log "cPads:Add(" + Char(34) + Target:GeoPosition:Lat + ", " + Target:GeoPosition:Lng + Char(34) + ")." to "Pads". }
} Else If cName <> "" and cLat <> 999999 and cLng <> 999999 {
  Log "cPads:Add(" + Char(34) + cName + Char(34) + ")." to "Pads". Log "cPads:Add(" + Char(34) + cLat + ", " + cLng + Char(34) + ")." to "Pads".
} Else If cName <> "" {
  List Targets in AllTargets. For cTarget in AllTargets { If cTarget:Name = cName { Log "cPads:Add(" + Char(34) + cTarget:Name + Char(34) + ")." to "Pads". Log "cPads:Add(" + Char(34) + cTarget:GeoPosition:Lat + ", " + cTarget:GeoPosition:Lng + Char(34) + ")." to "Pads". }}
}
ClearScreen. If cName = "" and cLat = 999999 AddPad().

Function AddPad {
  Print "                                              " at (0, 1).
  Print "                   ADD LOCATION               " at (0, 2).
  Print "                                              " at (0, 3).
  Print "                                              " at (0, 4).
  Print "         PAD:                                 " at (0, 5).
  Print "                                              " at (0, 6).
  Print "                                              " at (0, 7).
  Print "                                              " at (0, 8).
  Print "                                              " at (0, 9).
  Print "                                              " at (0, 10).
  Print "      Enter  = Add Location       Q = Exit    " at (0, 11).

  Set Pad to "". Set PadN to 0. Set cPad to "". Set LaunchPads to List(). Set RealLaunchPads to List().
  If Exists("Pads") = True { Set cPads to List(). Set RFile to Time:Seconds. CopyPath("Pads", RFile). RunPath(RFile). DeletePath(RFile). From { Set cPadN to 0. } Until cPadN > cPads:Length -3 Step { Set cPadN to cPadN + 3.} Do { RealLaunchPads:Add(cPads[cPadN]). RealLaunchPads:Add(LatLng(cPads[cPadN + 1]:Split(",")[0]:ToNumber, cPads[cPadN + 1]:Split(",")[1]:ToNumber)). }}
  LaunchPads:Add("'Current'"). LaunchPads:Add(Ship:GeoPosition).
  If HasTarget = True and Target:Body:Name = Body:Name { LaunchPads:Add("'Target (" + Target:Name +")'"). LaunchPads:Add(Target:GeoPosition). }
  For cWaypoint in AllWaypoints() { If cWaypoint:Body = Ship:Body and RealLaunchPads:Find(cWaypoint:Name) = -1 { Set AddWaypoint to True. From { Set cPadN to 0. } Until cPadN > RealLaunchPads:Length -2 Step { Set cPadN to cPadN + 2.} Do { If RealLaunchPads[cPadN] = cWaypoint:Name { Set AddWaypoint to False. Break. }} If AddWaypoint = True { LaunchPads:Add("'" + cWaypoint:Name + "'"). LaunchPads:Add(cWaypoint:GeoPosition). }}}
  Set Pad to LaunchPads[0]. Set LaunchPad to LaunchPads[1]. Set LaunchPadAlt to Round(Max(LaunchPad:TerrainHeight, 0)).

  Until Done = True {
    If Pad = "'Current'" { Set LaunchPad to Ship:GeoPosition. Set LaunchPadAlt to Round(Max(LaunchPad:TerrainHeight, 0)). }
    If HasTarget = True and Pad = "'Target (" + Target:Name +")'" { Set LaunchPad to Target:GeoPosition. Set LaunchPadAlt to Round(Max(LaunchPad:TerrainHeight, 0)). }
    Print Pad + " (" + LaunchPadAlt + " m.)" + "                                   ":SubString((Pad + "(" + Round(LaunchPadAlt) + " m.)"):Length, Max(34 - (Pad + "(" + LaunchPadAlt + " m.)"):Length, 0)) at (15, 5).
    If Terminal:Input:HasChar {
      Set ch to Terminal:Input:GetChar().
      If ch = Terminal:Input:LeftCursorOne and LaunchPads:Length > 1 { If PadN = 0 { Set PadN to LaunchPads:Length - 2. } Else { Set PadN to PadN - 2. } Set Pad to LaunchPads[PadN]. Set LaunchPad to LaunchPads[PadN + 1]. Set LaunchPadAlt to Round(Max(LaunchPad:TerrainHeight, 0)). }
      If ch = Terminal:Input:RightCursorOne and LaunchPads:Length > 1 { If PadN = LaunchPads:Length - 2 { Set PadN to 0. } Else { Set PadN to PadN + 2. } Set Pad to LaunchPads[PadN]. Set LaunchPad to LaunchPads[PadN + 1]. Set LaunchPadAlt to Round(Max(LaunchPad:TerrainHeight, 0)). }
      If ch = "q" { Set Exit to True. Set Done to True. }
      If ch = Terminal:Input:Enter and Pad <> "" {
        If Pad = "'Current'" Set Pad to Ship:Name. If HasTarget = True If Pad = "'Target (" + Target:Name +")'" Set Pad to Target:Name.
        If Pad:Substring(0, 1) = "'" Set Pad to Pad:Substring(1, Pad:Length - 2).
        Log "cPads:Add(" + Char(34) + Pad + Char(34) + ")." to "Pads". 
        Log "cPads:Add(" + Char(34) + LaunchPad:Lat + ", " + LaunchPad:Lng + Char(34) + ")." to "Pads".
        Log "cPads:Add(" + Char(34) + LaunchPad:Body:Name + Char(34) + ")." to "Pads".
        Print "         PAD:                                 " at (0, 5).
        Print "           " + Pad + " added                  " at (0, 17).
        Set Done to True.
      }
    }
  }
  Set Done to False. If Exit = False { AddPad(). } Else { ClearScreen. }
}