// USAGE: Run GoToPad.

//////////////////////////////////////
/////// VARIABLES FOR TWEAKING ///////
//////////////////////////////////////

Parameter Pad is "".					// [Pad_Name], [Vessel_Name], "Target" or "[LAT], [LNG]"
Set MaxDistancePads to 50000.				// Show Pads closest than this value in meters (only when landed)
Set MaxSlope to 5.					// Maximum slope angle for landing (only when Auto-Slope = 'Yes')

Set Config:IPU to 500.					// Change IPU settings

//////////////////////////////////////
/////// VARIABLES FOR TWEAKING ///////
//////////////////////////////////////

// .==============.
// |  REQUISITES  |
// |==============|

ClearScreen. Set Ship:Control:PilotMainThrottle to 0.
If Addons:TR:Available = False {
  Print "                     GO TO PAD                    " at (0, 2).
  Print "     .======================================.     " at (0, 14).
  Print "     |       TRAJECTORIES NOT INSTALLED     |     " at (0, 15).
  Print "     |======================================|     " at (0, 16).
  Print "               Press 'ENTER' to exit              " at (0, 22).
  Until False { If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar(). If ch = Terminal:Input:Enter { ClearScreen. Reboot. }} Wait 0.001. }
}

If Alt:Radar > MaxDistancePads * 2 or GroundSpeed > 500 {
  Print "                     GO TO PAD                    " at (0, 2).
  Print "     .======================================.     " at (0, 12).
  Print "     | WAITING FOR LOW ALTITUD AND VELOCITY |     " at (0, 13).
  Print "     |--------------------------------------|     " at (0, 14).
  Print "     | ALTITUDE:        | VELOCITY:         |     " at (0, 15).
  Print "     |======================================|     " at (0, 16).
  Print "               Press 'ENTER' to exit              " at (0, 22).
  Until False {
    If Alt:Radar - (MaxDistancePads * 2) <= 0 { Set CheckAlt to "OK". } Else { Set CheckAlt to FormatDistance(Alt:Radar - (MaxDistancePads * 2)). }
    If GroundSpeed - 500 <= 0 { Set CheckVel to "OK". } Else { FormatDistance(GroundSpeed - 500). }
    Print CheckAlt + Spacer(CheckAlt:Length, 7) at (17, 15).
    Print CheckVel + Spacer(CheckVel:Length, 8) at (36, 15).
    If CheckAlt = "OK" and CheckVel = "OK" Break.
    If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar(). If ch = Terminal:Input:Enter { ClearScreen. Reboot. }}
    Wait 0.001. 
  }
}

///////////////////////////
/////// LAUNCH-PADS ///////
///////////////////////////

Set PadN to 0. Set LaunchPads to List().
If Ship:Body:Name = "Kerbin" {
  If GeoPositionDistance(Ship:GeoPosition, LatLng(-0.097207, -74.557672)) < MaxDistancePads { LaunchPads:Add("LaunchPad").			LaunchPads:Add(LatLng(-0.097207, -74.557672)). LaunchPads:Add(Body:Name). }
  If GeoPositionDistance(Ship:GeoPosition, LatLng(-0.096808, -74.617447)) < MaxDistancePads { LaunchPads:Add("Pad1"). 	    			LaunchPads:Add(LatLng(-0.096808, -74.617447)). LaunchPads:Add(Body:Name). }
  If GeoPositionDistance(Ship:GeoPosition, LatLng(-0.096767, -74.620048)) < MaxDistancePads { LaunchPads:Add("Pad2"). 	    			LaunchPads:Add(LatLng(-0.096767, -74.620048)). LaunchPads:Add(Body:Name). }
  If GeoPositionDistance(Ship:GeoPosition, LatLng(-0.092562, -74.663084)) < MaxDistancePads { LaunchPads:Add("HeliPad").    			LaunchPads:Add(LatLng(-0.092562, -74.663084)). LaunchPads:Add(Body:Name). }
  If GeoPositionDistance(Ship:GeoPosition, LatLng(-1.519712, -71.899433)) < MaxDistancePads { LaunchPads:Add("Island Airfield"). 		LaunchPads:Add(LatLng(-1.519712, -71.899433)). LaunchPads:Add(Body:Name). }
  If GeoPositionDistance(Ship:GeoPosition, LatLng(-1.523246, -71.911106)) < MaxDistancePads { LaunchPads:Add("Island Airfield (Tower)"). 	LaunchPads:Add(LatLng(-1.523246, -71.911106)). LaunchPads:Add(Body:Name). }
  If GeoPositionDistance(Ship:GeoPosition, LatLng(-0.086810, -74.661199)) < MaxDistancePads { LaunchPads:Add("KSC Pool"). 			LaunchPads:Add(LatLng(-0.086810, -74.661199)). LaunchPads:Add(Body:Name). }
  If GeoPositionDistance(Ship:GeoPosition, LatLng(-6.056890,  99.471429)) < MaxDistancePads { LaunchPads:Add("Round Range").    		LaunchPads:Add(LatLng(-6.056890,  99.471429)). LaunchPads:Add(Body:Name). }
  If GeoPositionDistance(Ship:GeoPosition, LatLng(20.663470,-146.420970)) < MaxDistancePads { LaunchPads:Add("KSC 2").   			LaunchPads:Add(LatLng( 20.66347,-146.420970)). LaunchPads:Add(Body:Name). }
}
If HasTarget = True and Target:Body:Name = Body:Name { If GeoPositionDistance(Ship:GeoPosition, Target:GeoPosition) < MaxDistancePads { LaunchPads:Add("'Target'"). LaunchPads:Add(Target:GeoPosition). LaunchPads:Add(Body:Name). }}
If Exists("Pads") = True { Set cPads to List(). Run Pads. From { Set cPadN to 0. } Until cPadN > cPads:Length -3 Step { Set cPadN to cPadN + 3.} Do { If cPads[cPadN + 2] = Body:Name { If GeoPositionDistance(Ship:GeoPosition, LatLng(cPads[cPadN + 1]:Split(",")[0]:ToNumber, cPads[cPadN + 1]:Split(",")[1]:ToNumber)) < MaxDistancePads { LaunchPads:Add(cPads[cPadN]). LaunchPads:Add(LatLng(cPads[cPadN + 1]:Split(",")[0]:ToNumber, cPads[cPadN + 1]:Split(",")[1]:ToNumber)). LaunchPads:Add(cPads[cPadN + 2]). }}}}
For cWaypoint in AllWaypoints() { If cWaypoint:Body:Name = Ship:Body:Name { If GeoPositionDistance(Ship:GeoPosition, cWaypoint:GeoPosition) < MaxDistancePads { Set AddWaypoint to True. From { Set cPadN to 0. } Until cPadN > LaunchPads:Length -3 Step { Set cPadN to cPadN + 3.} Do { If LaunchPads[cPadN] = cWaypoint:Name and LaunchPads[cPadN + 1] = cWaypoint:GeoPosition { Set AddWaypoint to False. Break. }} If AddWaypoint = True { LaunchPads:Add("'" + cWaypoint:Name + "'"). LaunchPads:Add(cWaypoint:GeoPosition). LaunchPads:Add(cWaypoint:Body:Name). }}}}
List Targets in AllTargets. For cTarget in AllTargets { If cTarget:Body:Name = Body:Name { If GeoPositionDistance(Ship:GeoPosition, cTarget:GeoPosition) < MaxDistancePads { LaunchPads:Add("'" + cTarget:Name + "'"). LaunchPads:Add(cTarget:GeoPosition). LaunchPads:Add(cTarget:Body:Name). }}}
If ShipStatus = "Flying" { LaunchPads:Add("Anywhere"). LaunchPads:Add(LatLng(0, 0)). LaunchPads:Add(Body:Name). }

Set cPad to "". If LaunchPads:Length > 0 { From { Set cPadN to 0. } Until cPadN > LaunchPads:Length -3 Step { Set cPadN to cPadN + 3.} Do { If LaunchPads[cPadN] = Pad { Set PadN to cPadN. Set Pad to LaunchPads[cPadN]. Set LaunchPad to LaunchPads[cPadN + 1]. Set cPad to Pad. Break. }}}
If cPad = "" and Pad:Contains(",") = True { Set GeoPosLat to Pad:Split(",")[0]. Set GeoPosLng to Pad:Split(",")[1]. Set GeoPos to LatLng(GeoPosLat:ToNumber, GeoPosLng:ToNumber). If GeoPositionDistance(Ship:GeoPosition, GeoPos) < MaxDistancePads { Set Pad to "'" + Round(GeoPos:Lat, 3)+ ", " + Round(GeoPos:Lng, 3) + "'". LaunchPads:Add(Pad). LaunchPads:Add(GeoPos). LaunchPads:Add(body:Name). Set PadN to LaunchPads:Length -3. Set LaunchPad to GeoPos. Set cPad to Pad. }}
If LaunchPads:Length = 0 { Set Pad to "No Pads". } Else { Set Pad to LaunchPads[0]. Set LaunchPad to LaunchPads[1]. Set OriginalLaunchPad to LaunchPad. }

Until LaunchPads:Length > 0 {
  Print "                     GO TO PAD                    " at (0, 2).
  Print "     .======================================.     " at (0, 14).
  Print "     |                NO PADS               |     " at (0, 15).
  Print "     |======================================|     " at (0, 16).
  Print "               Press 'ENTER' to exit              " at (0, 22).
  If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar(). If ch = Terminal:Input:Enter { ClearScreen. Reboot. }}
  Wait 0.001. 
}

/////////////////////////
/////// VARIABLES ///////
/////////////////////////

Set LandingCompleted to False. Set RunMode to 1. Set UpdateSettings to True. Set UpdateLaunchPad to False.
Set SettingsShown to False. Set Offset to 0. Set OriginalOffset to 0. Set AutoSlope to "Yes".

/////////////////////////
/////// PRE-START ///////
/////////////////////////

Print "                     GO TO PAD                    " at (0, 2).
Print "     .======================================.     " at (0, 4).
Print "     | (< >) PAD:                           |     " at (0, 5).
Print "  .=============================================. " at (0, 6).
Print "  | Terrain Alt:         | Distance:            | " at (0, 7).
Print "  |=============================================| " at (0, 8).
Print "  .=============================================. " at (0, 10).
Print "  | (P) Auto-Slope:      | (O) Offset:          | " at (0, 11).
Print "  |=============================================| " at (0, 12).
Print "                                                  " at (0, 15).
Print "                                                  " at (0, 16).
Print "                                                  " at (0, 22).

Set StartProgram to False. Until StartProgram = True {
  If Pad = "No Pads" {
    If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar(). If ch = Terminal:Input:Enter { ClearScreen. Reboot. }}
  } Else {
    If LaunchPad:Lat = 0 and LaunchPad:Lng = 0 { Set PLaunchPadAlt to "    -". } Else { Set PLaunchPadAlt to FormatDistance(Max(LaunchPad:TerrainHeight, 0), 1). }
    If LaunchPad:Lat = 0 and LaunchPad:Lng = 0 { Set PLaunchPadDist to "    -". } Else { Set PLaunchPadDist to FormatDistance(GeoPositionDistance(Ship:GeoPosition, OriginalLaunchPad, Body:Radius + Altitude), 1). }
    If Pad = "Anywhere" { Set PLaunchPadOffset to "N/A". } Else { Set PLaunchPadOffset to FormatDistance(Offset, 1). }

    Print Pad + Spacer(Pad:Length, 26) at (18, 5).
    Print PLaunchPadAlt + Spacer(PLaunchPadAlt:Length, 8) at (17, 7). 		Print PLaunchPadDist + Spacer(PLaunchPadDist:Length, 10) at (38, 7).
    Print AutoSlope + Spacer(AutoSlope:Length, 5) at (20, 11). 			Print PLaunchPadOffset + Spacer(PLaunchPadOffset:Length, 8) at (40, 11).

    If Terminal:Input:HasChar { Set ch to Terminal:Input:GetChar().
      If ch = Terminal:Input:LeftCursorOne { If PadN = -1 Set PadN to 0. If PadN = 0 { Set PadN to LaunchPads:Length - 3. } Else { Set PadN to PadN - 3. } Set Pad to LaunchPads[PadN]. Set LaunchPad to LaunchPads[PadN + 1]. Set OriginalLaunchPad to LaunchPad. }
      If ch = Terminal:Input:RightCursorOne { If PadN = -1 Set PadN to LaunchPads:Length - 3. If PadN = LaunchPads:Length - 3 { Set PadN to 0. } Else { Set PadN to PadN + 3. } Set Pad to LaunchPads[PadN]. Set LaunchPad to LaunchPads[PadN + 1]. Set OriginalLaunchPad to LaunchPad. }
      If ch = "p" If AutoSlope = "Yes" { Set AutoSlope to "No". } Else { Set AutoSlope to "Yes". }
      If Pad <> "Anywhere" {
        If UnChar(ch) = 111 { If OriginalOffset < 100 Set Offset to Offset + 1. Set OriginalOffset to OriginalOffset + 1. Set LaunchPad to GeoPositionAt(OriginalLaunchPad, OriginalOffset, -GeoPositionBearing(Ship:GeoPosition, OriginalLaunchPad)). }
        If UnChar(ch) = 79 { If OriginalOffset > 0 Set Offset to Offset - 1. Set OriginalOffset to OriginalOffset - 1. Set LaunchPad to GeoPositionAt(OriginalLaunchPad, OriginalOffset, -GeoPositionBearing(Ship:GeoPosition, OriginalLaunchPad)). }
      }
      If ch = Terminal:Input:Enter { Set StartProgram to True. If Pad = "'Target'" { If HasTarget = True { Set Pad to "'" + Target:Name + "'". Set LaunchPad to Target:GeoPosition. } Else { Set Pad to "Anywhere". Set LaunchPad to LatLng(0.0, 0.0). }}}
      If Terminal:Input:HasChar Terminal:Input:Clear.
    }
  Wait 0.001. 
  }
}

///////////////////////////
/////// INFORMATION ///////
///////////////////////////

Print "                     GO TO PAD                    " at (0, 2).
Print "      .=====================================.     " at (0, 4).
Print "      | PAD:                                |     " at (0, 5).
Print "      |-------------------------------------|     " at (0, 6).
Print "      | T-Alt:           | Dist:            |     " at (0, 7).
Print "      |-------------------------------------|     " at (0, 8).
Print "      | Slope:           | Offset:          |     " at (0, 9).
Print "      |=====================================|     " at (0, 10).
Print "                                                  " at (0, 11).
Print "      .=====================================.     " at (0, 12).
Print "      | FUEL:            | BATT:            |     " at (0, 13).
Print "      |=====================================|     " at (0, 14).
Print "                                                  " at (0, 15).
Set ch to " ". PrintInfo().

Function PrintInfo {
  If LaunchPad:Lat = 0 and LaunchPad:Lng = 0 { Set PLaunchPadAlt to " -". } Else If LaunchPad:TerrainHeight < 0 { Set PLaunchPadAlt to "Water". } Else { Set PLaunchPadAlt to FormatDistance(Max(LaunchPad:TerrainHeight, 0), 1). }
  If LaunchPad:Lat = 0 and LaunchPad:Lng = 0 { Set PLaunchPadDist to "    -". } Else { Set PLaunchPadDist to FormatDistance(GeoPositionDistance(Ship:GeoPosition, OriginalLaunchPad, Body:Radius + Altitude), 1). }
  If LaunchPad:Lat = 0 and LaunchPad:Lng = 0 { Set PLaunchPadSlope to " -". } Else If LaunchPad:TerrainHeight < 0 { Set PLaunchPadSlope to " -". } Else { Set PLaunchPadSlope to SlopeAt(LaunchPad, 1). }
  If Pad = "Anywhere" { Set PLaunchPadOffset to "N/A". } Else { Set PLaunchPadOffset to FormatDistance(Offset, 1). }

  Print Pad + Spacer(Pad:Length, 31) at (13, 5).
  Print PLaunchPadAlt + Spacer(PLaunchPadAlt:Length, 9) at (16, 7). 			Print PLaunchPadDist + Spacer(PLaunchPadDist:Length, 11) at (33, 7).
  Print PLaunchPadSlope + Spacer(PLaunchPadSlope:Length, 9) at (16, 9). 		Print PLaunchPadOffset + Spacer(PLaunchPadOffset:Length, 9) at (35, 9).
  Print GetResource(Ship, "LiquidFuel") + " %  " at (17, 13). 				Print GetResource(Ship, "ElectricCharge") + " %  " at (35, 13).

  If Terminal:Input:HasChar Set ch to Terminal:Input:GetChar(). Terminal:Input:Clear.
  If ch = "s" { If SettingsShown = True { Set SettingsShown to False. } Else { Set SettingsShown to True. }}
  If ch = "l" and ShipStatus = "Flying" and Pad <> "Anywhere" { Set Pad to "Anywhere". Set UpdateSettings to True. }

  If SettingsShown = True {
    Print "  .=============================================. " at (0, 16).
    Print "  | (P) Auto-Slope:" at (0, 17). Print "| (O) Offset:"  at (25, 17). Print "| " at (48, 17).
    Print "  |=============================================| " at (0, 18).
    Print AutoSlope + Spacer(AutoSlope:Length, 5) at (20, 17). 				Print PLaunchPadOffset + Spacer(PLaunchPadOffset:Length, 8) at (40, 17).
    If Pad = "Anywhere" { Print "N/A      " at (39, 17). Print "                    Settings = S                  " at (0, 20). } Else { If ShipStatus <> "Flying" {  Print "                    Settings = S                  " at (0, 20). } Else { Print "          Settings = S    Land anywhere = L       " at (0, 20). }}
    If ch = "p" { If AutoSlope = "Yes" { Set AutoSlope to "No". Set Offset to OriginalOffset. } Else { Set AutoSlope to "Yes". } Set UpdateLaunchPad to True. }
    If Pad <> "Anywhere" {
      If UnChar(ch) = 111 { If OriginalOffset < 100 { Set Offset to Offset + 1. Set OriginalOffset to OriginalOffset + 1. Set UpdateLaunchPad to True. }}
      If UnChar(ch) = 79 { If OriginalOffset > 0 { Set Offset to Offset - 1. Set OriginalOffset to OriginalOffset - 1. Set UpdateLaunchPad to True. }}
    }
  } Else {
    Print "                                                  " at (0, 17).
    Print "                                                  " at (0, 18).
    Print "                                                  " at (0, 20).
    If Pad = "Anywhere" { Print "                    Settings = S                  " at (0, 16). } Else { If ShipStatus <> "Flying" {  Print "                    Settings = S                  " at (0, 16). } Else { Print "          Settings = S    Land anywhere = L       " at (0, 16). }}
  } Set ch to " ".
}

Until LandingCompleted = True { SAS Off.

			///////////////////////
			/////// LANDING ///////
			///////////////////////
  If RunMode = 1 {
    If ShipStatus = "Landed" { If GeoPositionDistance(Ship:GeoPosition, LaunchPad) < 5 or AvailableThrust = 0 { Set LandingCompleted to True. Set Started to False. }} If ShipStatus = "Splashed" { Set LandingCompleted to True. Set Started to False. }

    If LandingCompleted = False {
      If UpdateSettings = True { Set UpdateSettings to False.
        Set ShipHeight to GetShipHeight(Ship). Lock TrueAltitude to Altitude + ShipHeight. Lock TrueRadar to Alt:Radar + ShipHeight. Set HoverAlt to 0. Lock TargetAlt to HoverAlt + ShipHeight. InitSteeringPIDs. Lock Steering to Heading(SteeringDir, SteeringPitch).

        If Pad = "Anywhere" { If GroundSpeed > 2 { Set LaunchPad to GeoPositionAt(Ship:GeoPosition, -10). If AutoSlope = "Yes" and SlopeAt(LaunchPad, 1):ToNumber > MaxSlope { Set LaunchPad to FindSlope(LaunchPad, MaxSlope, 5, 5). } InitSteeringPIDs. }}
        If Pad = "Anywhere" { When GroundSpeed < 2 Then { Set LaunchPad to Ship:GeoPosition. If AutoSlope = "Yes" and SlopeAt(LaunchPad, 1):ToNumber > MaxSlope { Set LaunchPad to FindSlope(LaunchPad, MaxSlope, 1, 1). } InitSteeringPIDs. }}
        If Pad <> "Anywhere" { If AutoSlope = "Yes" and SlopeAt(LaunchPad, 1):ToNumber > MaxSlope { Set LaunchPad to FindSlope(OriginalLaunchPad, MaxSlope, OriginalOffset, 5). InitSteeringPIDs. }}
     
        Set IdealThrottle to Throttle. Lock Throttle to IdealThrottle. Set Throttle_PID to PIDLoop(0.3, 0.3, 0.005, 0, 1).
        Set HoverHeight to List(Time:Seconds, 0). Set T to 0. Set Correction to 1.9. Set Started to True.
        When GeoPositionDistance(Ship:GeoPosition, LaunchPad) < 50 Then { Gear On. }
      }

      If UpdateLaunchPad = True { If AutoSlope = "Yes" and SlopeAt(LaunchPad, 1):ToNumber > MaxSlope { Set LaunchPad to FindSlope(OriginalLaunchPad, MaxSlope, OriginalOffset, 5). } Else { Set LaunchPad to GeoPositionAt(OriginalLaunchPad, OriginalOffset, -GeoPositionBearing(Ship:GeoPosition, OriginalLaunchPad)). } InitSteeringPIDs. Set UpdateLaunchPad to False. }
      
      If GeoPositionImpact(LaunchPad) < 3 and GroundSpeed < 1 and ShipStatus <> "Landed" { SteeringPIDs(5). Set HoverAlt to 0. } Else { SteeringPIDs(75). Set HoverAlt to HighestPoint(MAX(GeoPositionDistance(Ship:GeoPosition, LaunchPad), 5)) + 10. }
      If GeoPositionDistance(Ship:GeoPosition, LaunchPad) < 5 and ShipStatus <> "Flying" { Set LandingCompleted to True. Set Started to False. Set IdealThrottle to 0. Lock Throttle to IdealThrottle. }
      Hover().
    }
  } PrintInfo(). Wait 0.001.
} ClearScreen.

// .=====================================================================.
// |                              FUNCTIONS                              |
// |=====================================================================|

Function Hover {
  If Started = True {
    If TargetAlt < TrueRadar and TrueRadar < 10 {
      Set IdealThrottle to Throttle_PID:Update(Time:Seconds, VerticalSpeed). Set Throttle_PID:SetPoint to -MIN((TrueRadar / 2), 1). //Set Throttle_PID:SetPoint to -Min((TrueRadar / 2) / 2, 3).
    } Else {
      Local Maxa is 21. If MaxThrust > 0 and Mass > 0 Set Maxa to MaxThrust / Mass.
      Set IdealThrottle to Seek(HoverHeight, TargetAlt - TrueAltitude, Maxa, Correction, Body:MU / (TrueAltitude + Body:Radius)^2).
    }
  }
}

// .=======================.
// | GEO-POSITION DISTANCE |
// |=======================|

Function GeoPositionDistance { Parameter GeoPos1, GeoPos2, Alt is 0. Set Alt to Alt + Body:Radius.
  Local A is SIN((GeoPos1:LAT - GeoPos2:LAT) / 2)^2 + COS(GeoPos1:LAT) * COS(GeoPos2:LAT) * SIN((GeoPos1:LNG - GeoPos2:LNG) / 2)^2.
  Return Alt * Constant:PI * ArcTan2(SQRT(A), SQRT(1 - A)) / 90.
}
Function GeoPositionDistanceLNG { Parameter GeoPos1, GeoPosLNG, Alt is 0. Set Alt to Alt + Body:Radius.
  Local A is SIN((GeoPos1:LAT - GeoPos1:LAT) / 2)^2 + COS(GeoPos1:LAT) * COS(GeoPos1:LAT) * SIN((GeoPos1:LNG - GeoPosLNG) / 2)^2.
  Return Alt * Constant:PI * ArcTan2(SQRT(A), SQRT(1 - A)) / 90.
}
Function GeoPositionDistanceLAT { Parameter GeoPos1, GeoPosLAT, Alt is 0. Set Alt to Alt + Body:Radius.
  Local A is SIN((GeoPos1:LAT - GeoPosLAT) / 2)^2 + COS(GeoPos1:LAT) * COS(GeoPosLAT) * SIN((GeoPos1:LNG - GeoPos1:LNG) / 2)^2.
  Return Alt * Constant:PI * ArcTan2(SQRT(A), SQRT(1 - A)) / 90.
}

// .=====================.
// | GEO-POSITION IMPACT |
// |=====================|

Function GeoPositionImpact { Parameter GeoPos. If Addons:TR:HasImpact = True { Return (GeoPos:Position - Addons:TR:ImpactPos:Position):MAG. } Else { Return 9999999. }}

// .======================.
// | GEO-POSITION BEARING |
// |======================|

Function GeoPositionBearing { Parameter GeoPos1, GeoPos2. Return Mod(360 + ArcTan2(Sin(GeoPos2:Lng - GeoPos1:Lng) * Cos(GeoPos2:Lat), Cos(GeoPos1:Lat) * Sin(GeoPos2:Lat) - Sin(GeoPos1:Lat) * Cos(GeoPos2:Lat) * Cos(GeoPos2:Lng - GeoPos1:Lng)), 360). }

// .=================.
// | GEO-POSITION AT |
// |=================|

Function GeoPositionAt {
  Parameter GeoPos, cDistance, cBearing is Mod(360 - LatLng(90,0):Bearing, 360).

  Local Lat is ArcSin(Sin(GeoPos:Lat) * Cos((cDistance * 180) / (Body:Radius * Constant:PI)) + Cos(GeoPos:Lat) * Sin((cDistance * 180) / (Body:Radius * Constant:PI)) * Cos(cBearing)).
  Local Lng is 0. If ABS(Lat) <> 90 Local Lng is GeoPos:Lng + ArcTan2(Sin(cBearing) * Sin((cDistance * 180) / (Body:Radius * Constant:PI)) * Cos(GeoPos:Lat), Cos((cDistance * 180)/(Body:Radius * Constant:PI)) - Sin(GeoPos:Lat) * Sin(Lat)).
  Return LatLng(Lat, Lng).
}

// .===============.
// | HIGHEST POINT |
// |===============|

Function HighestPoint { Parameter ScanDist is 600. Parameter ScanFineDist is 5.
  If Not (Defined DelayedExcecution) Set DelayedExcecution to Time:Seconds. If Not (Defined MaxAlt) Set MaxAlt to -10000.
  If (Not MapView and Time:Seconds > DelayedExcecution + 3) { Set DelayedExcecution to Time:Seconds. Set MaxAlt to -1000. Set Current to ScanFineDist.
    Until Current > ScanDist { Set Pos to Ship:Position + Current * Ship:SRFPrograde:Vector. Set MaxAlt to MAX(Ship:Body:GeoPositionOf(Pos):TerrainHeight, MaxAlt). Set Current to Current + ScanFineDist. }
  } Return MAX(MaxAlt, 0).
}

// .=============.
// | SHIP HEIGHT |
// |=============|

Function GetShipHeight { Parameter cVessel. Set LowestPart to 0. Set HighestPart to 0. Lock R3 to cVessel:Facing:ForeVector. Set PartList to cVessel:Parts.
  For Part in PartList{ Set V to Part:Position. Set CurrentPart to R3:X * V:X + R3:Y * V:Y + R3:Z * V:Z. If CurrentPart > HighestPart Set HighestPart to CurrentPart. Else If CurrentPart < LowestPart Set LowestPart to CurrentPart. }
  Return HighestPart - LowestPart.
}

// .==============.
// | GET RESOURCE |
// |==============|

Function GetResource {
  Parameter cVessel, cResourceName.		//[Vessel] or "Stage", "[Resource Name]"
  Set TotalFuel to 0. Set CurrentFuel to 0.
  For Res in cVessel:Resources { If Res:Name = cResourceName { Set TotalFuel to TotalFuel + Res:Capacity. Set CurrentFuel to CurrentFuel + Res:Amount. }}
  If CurrentFuel > 0 { Return Round((CurrentFuel * 100) / TotalFuel). } Else { Return 0. }
}

// .========================.
// | FORMAT DISTANCE / TIME |
// |========================|

Function FormatDistance { Parameter Value, Decimals is 0.
  If Value < 1000 { Return Max(Round(Value), 0) + " m.".
  } Else If Value < 100000 {
    Local Result to Max(Round(Value / 1000, Decimals), 0) + "".
    If Decimals > 0 { If Result:Contains(".") = False { Return Result + "." + "0000000000":SubString(0, Decimals) + " km.". } Else { Return Result + " km.". }}} Else { Return Max(Round(Value / 1000), 0) + " km.".
  }
}

Function FormatTime { Parameter PSeconds. Parameter Parentesis is True. Parameter NoNegative is False. If NoNegative = True and PSeconds < 0 Set PSeconds to 0.
  Set d to Floor(PSeconds / 21600). Set h to Floor((PSeconds - 21600 * d) / 3600). Set m to Floor((PSeconds - 3600 * h - 21600 * d) / 60).
  If m < 10 { Set sm to "0" + m. } Else { Set sm to m. } Set s to Round(PSeconds) - m * 60 - h * 3600 - 21600 * d. If s < 10 { Set ss to "0" + s. } Else { Set ss to s. }
  If d = 1 { Set fdays to d + " day - ". } Else { Set fdays to d + " days - ". } Set h to h + ((d * 21600) / 3600). Set d to 0.
  If Parentesis = True { If d = 0 { Return "(" + h + ":" + sm + ":" + ss + ")". } Else { Return "(" + fdays + h + ":" + sm + ":" + ss + ")". }} Else { If d = 0 { Return h + ":" + sm + ":" + ss. } Else { Return fdays + h + ":" + sm + ":" + ss. }}
}

// .==========.
// | STEERING |
// |==========|

Function InitSteeringPIDs { Parameter MaxAngle is 40.
  Set EastVelPID to PIDLoop(3, 0.01, 0.0, -MaxAngle, MaxAngle). Set EastPosPID to PIDLoop(1700, 0, 100, -30, 30). Set EastPosPID:SetPoint to LaunchPad:LNG.
  Set NorthVelPID to PIDLoop(3, 0.01, 0.0, -MaxAngle, MaxAngle). Set NorthPosPID to PIDLoop(1700, 0, 100, -30, 30). Set NorthPosPID:SetPoint to LaunchPad:LAT.
  Set SteeringPitch to 90. Set SteeringDir to 0.
}

Function SteeringPIDs { Parameter MaxSpeed is 80.
  Local NorthVec is Ship:North:ForeVector. Local UpVec is Ship:Up:Vector. Local EastVec is VCRS(UpVec, NorthVec).
  Local NorthSpeed is VDOT(NorthVec, Ship:Velocity:Surface). Local UpSpeed is VDOT(UpVec, Ship:Velocity:Surface). Local EastSpeed is VDOT(EastVec, Ship:Velocity:Surface).
  Set GSVectorCached to V(EastSpeed, UpSpeed, NorthSpeed).

  Local DistLAT to GeoPositionDistanceLAT(Ship:GeoPosition, LaunchPad:LAT). Local DistLNG to GeoPositionDistanceLNG(Ship:GeoPosition, LaunchPad:LNG). Set OtherSpeed to 0.
  If DistLAT > DistLNG { Set OtherSpeed to (DistLNG * MaxSpeed) / DistLAT. Set NorthPosPID:MINOUTPUT to -MaxSpeed. Set NorthPosPID:MAXOUTPUT to MaxSpeed. Set EastPosPID:MINOUTPUT to -OtherSpeed. Set EastPosPID:MAXOUTPUT to OtherSpeed.
  } Else { Set OtherSpeed to (DistLAT * MaxSpeed) / DistLNG. Set NorthPosPID:MINOUTPUT to -OtherSpeed. Set NorthPosPID:MAXOUTPUT to OtherSpeed. Set EastPosPID:MINOUTPUT to -MaxSpeed. Set EastPosPID:MAXOUTPUT to MaxSpeed. }

  Set EastVelPID:SetPoint to EastPosPID:Update (Time:Seconds, Ship:GeoPosition:LNG). Local EastVelPIDOut is EastVelPID:Update (Time:Seconds, GSVectorCached:X).
  Set NorthVelPID:SetPoint to NorthPosPID:Update (Time:Seconds, Ship:GeoPosition:LAT). Local NorthVelPIDOut is NorthVelPID:Update (Time:Seconds, GSVectorCached:Z).
  Local SteeringDirNonNorm is ArcTan2(EastVelPID:Output, NorthVelPID:Output). If SteeringDirNonNorm >= 0 { Set SteeringDir to SteeringDirNonNorm. } Else { Set SteeringDir to 360 + SteeringDirNonNorm. }
  Set SteeringPitch to 90 - Max(ABS(EastVelPIDOut), ABS(NorthVelPIDOut)).
}

// .=====.
// | TWR |
// |=====|

Function TWR {
  Parameter TWRMode, cAltitude is Altitude.	// "CUR" -> Current | "MAX" -> Maximum | [Number] -> Set TWR
  If TWRMode = "CUR" or TWRMode = "MAX" {
    Set mThrust to 0. Set cThrust to 0. List Engines in EngList.
    For Eng in EngList { If Eng:Name:Contains("decoupler") = False and Eng:Name:Contains("heatshield") = False {Set cThrust to cThrust + Eng:Thrust. If Eng:Ignition = True Set mThrust to mThrust + Eng:AvailableThrust. }}
    Set cThrust to Round(cThrust / ((Body:Mu / (Body:Radius + cAltitude)^2) * Mass), 2) + "". If cThrust:Contains(".") = True { If (cThrust + ""):Length - cThrust:Find(".") = 2 Set cThrust to cThrust + "0". } Else { Set cThrust to cThrust + ".00". }
    Set mThrust to Round(mThrust / ((Body:Mu / (Body:Radius + cAltitude)^2) * Mass), 2) + "". If mThrust:Contains(".") = True { If (mThrust + ""):Length - mThrust:Find(".") = 2 Set mThrust to mThrust + "0".  } Else { Set mThrust to mThrust + ".00". }
    If TWRMode = "CUR" Return cThrust. If TWRMode = "MAX" Return mThrust.
  } Else { Return Min(Max((TWRMode * (Constant:G * ((Mass * Body:Mass) / ((cAltitude + Body:Radius)^2)))) / (AvailableThrust + 0.001), 0), 1). }
}

// .=========.
// | VARIOUS |
// |=========|

Function ShipStatus { If Ship:Status = "Landed" or Ship:Status = "PreLaunch" { Return "Landed". } Else If Ship:Status = "Splashed" { Return "Splashed". } Else { Return "Flying". }}
Function Spacer { Parameter StringLength, SpaceLength. Local Spaces is "                                                  ":Substring(0, Max(Min(SpaceLength, 50), 0)). If StringLength >= SpaceLength Return "". Return Spaces:Substring(StringLength, Spaces:Length - StringLength). }
Function MaxVertDecel { If Velocity:Surface:MAG = 0 or AvailableThrust = 0 { Return 0. } Else { Return VerticalSpeed^2 / (2 * ((AvailableThrust / Mass) * (2 * (-VerticalSpeed / Velocity:Surface:MAG) + 1) / 3 - (Body:MU / Body:Radius^2))). }}

Function SlopeAt {
  Parameter GeoPos, cDistance.
  Local cSlope is 0.
  Local Pos1 to SlopeAngleTerrain(GeoPos, GeoPositionAt(GeoPos, cDistance, 0)). If cSlope < Pos1 Set cSlope to Pos1.
  Local Pos2 to SlopeAngleTerrain(GeoPos, GeoPositionAt(GeoPos, cDistance, 90)). If cSlope < Pos2 Set cSlope to Pos2.
  Local Pos3 to SlopeAngleTerrain(GeoPos, GeoPositionAt(GeoPos, cDistance, 180)). If cSlope < Pos3 Set cSlope to Pos3.
  Local Pos4 to SlopeAngleTerrain(GeoPos, GeoPositionAt(GeoPos, cDistance, 270)). If cSlope < Pos4 Set cSlope to Pos4.
  If (Round(cSlope, 1) + ""):Contains(".") = True { Return Round(cSlope, 1) + "". } Else { Return Round(cSlope, 1) + ".0". }
}

Function SlopeAngleTerrain { Parameter GeoPos1, GeoPos2. Return ArcTan(ABS(GeoPos1:TerrainHeight - GeoPos2:TerrainHeight) / (GeoPos1:Position - GeoPos2:Position):MAG). }

Function FindSlope {
  Parameter GeoPos, cMaxSlope, cDistance, cStep.
  Set cStep to 10.
  Local cSlope is 9999.
  Until cDistance > MaxDistancePads {
    Set NewGeoPos to GeoPositionAt(GeoPos, cDistance, 0). If SlopeAt(NewGeoPos, 1):ToNumber < cMaxSlope and NewGeoPos:TerrainHeight > 0 { Set Offset to GeoPositionDistance(GeoPos, NewGeoPos). Break. }
    Set NewGeoPos to GeoPositionAt(GeoPos, cDistance, 90). If SlopeAt(NewGeoPos, 1):ToNumber < cMaxSlope and NewGeoPos:TerrainHeight > 0 { Set Offset to GeoPositionDistance(GeoPos, NewGeoPos). Break. }
    Set NewGeoPos to GeoPositionAt(GeoPos, cDistance, 180). If SlopeAt(NewGeoPos, 1):ToNumber < cMaxSlope and NewGeoPos:TerrainHeight > 0 { Set Offset to GeoPositionDistance(GeoPos, NewGeoPos). Break. }
    Set NewGeoPos to GeoPositionAt(GeoPos, cDistance, 270). If SlopeAt(NewGeoPos, 1):ToNumber < cMaxSlope and NewGeoPos:TerrainHeight > 0 { Set Offset to GeoPositionDistance(GeoPos, NewGeoPos). Break. }
    Set cDistance to cDistance + cStep.
  }
  Return NewGeoPos.
}

Function VHeading {
  Parameter cVessel, cVector.
  Set cCompass to ArcTan2(vDot(cVector, VCRS(cVessel:Up:Vector, cVessel:North:Vector)), vDot(cVector, cVessel:North:Vector)).
  If cCompass < 0 Set cCompass to cCompass + 360.
  Return cCompass.
  //USAGE VHeading(Ship, North:Vector).	Will result in 0 or 360 => both pointing North
  //Print "Compass of srf prograde: " + Round(VHeading(Ship, Ship:Velocity:Surface), 1) + " deg " at (0,2).
  //Print "Compass of orb prograde: " + Round(VHeading(Ship, Ship:Velocity:Orbit), 1) + " deg " at (0,3).
  //Print "Compass of ship facing : " + Round(VHeading(Ship, Ship:Facing:ForeVector), 1) + " deg " at (0,4).
}

Function Seek { Parameter Deltas, Target, Authority, Aggro, Trim.
  Local DT is Time:Seconds - Deltas[0].
  Local Vel is 0. If DT <> 0 Set Vel to (Target - Deltas[1]) / DT.
  Set Deltas[0] to Time:Seconds. Set Deltas[1] to Target.
  Return ((Target + (Vel * ABS(Vel)) / (Authority / Aggro) + Vel) + Trim) / Authority.
}




///// OTROS

Function GetImpactTime { If VerticalSpeed < 0 { Return Round(ABS(TrueAltitude / VerticalSpeed)). } Else { Return 9999999. }}
Function GetStopDistance { Local cStopDistance to (((SIN(VANG(Ship:Up:Vector, Ship:Velocity:Surface * -1)) * AvailableThrust) / Mass) * ((GroundSpeed - SQRT(ABS(VerticalSpeed))) / ((SIN(VANG(Ship:Up:Vector, Ship:Velocity:Surface * -1)) * AvailableThrust) / Mass))^2) / 2. Return cStopDistance + (cStopDistance / 10). }
Function HasEngines { Local NoEngines is True. List Engines in Engs. For Eng in Engines { If Eng:FlameOut = False { If Eng:Ignition = False and Eng:AllowRestart = True and Eng:Stage < Stage:Number Set NoEngines to False. }} Return Not NoEngines. }

// .========.
// | CHUTES |
// |========|

Function Chutes { Parameter Action is "True", IgnoreTag is "".
  If Action = "True" {
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteFAR" { If Part:GetModule("RealChuteFAR"):HasAction("Arm Parachute") = True Part:GetModule("RealChuteFAR"):DoAction("Arm Parachute", True). } If Module = "RealChuteModule" { If Part:GetModule("RealChuteModule"):HasAction("Arm Parachute") = True Part:GetModule("RealChuteModule"):DoAction("Arm Parachute", True). }}}
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteFAR" { If Part:GetModule("RealChuteFAR"):HasAction("Deploy Chute") = True Part:GetModule("RealChuteFAR"):DoAction("Deploy Chute", True). } If Module = "RealChuteModule" { If Part:GetModule("RealChuteModule"):HasAction("Deploy Chute") = True Part:GetModule("RealChuteModule"):DoAction("Deploy Chute", True). }}}
  } Else If Action = "False" {
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteFAR" { If Part:GetModule("RealChuteFAR"):HasAction("Disarm Parachute") = True Part:GetModule("RealChuteFAR"):DoAction("Disarm Parachute", True). } If Module = "RealChuteModule" { If Part:GetModule("RealChuteModule"):HasAction("Disarm Parachute") = True Part:GetModule("RealChuteModule"):DoAction("Disarm Parachute", True). }}}
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteFAR" { If Part:GetModule("RealChuteFAR"):HasAction("Disarm chute") = True Part:GetModule("RealChuteFAR"):DoAction("Disarm chute", True). } If Module = "RealChuteModule" { If Part:GetModule("RealChuteModule"):HasAction("Disarm chute") = True Part:GetModule("RealChuteModule"):DoAction("Disarm chute", True). }}}
  } Else If Action = "Exist" {
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteModule" or Module = "RealChuteFAR" Return True. }} Return False.
  } Else If Action = "Deployed" {
    List Parts in PartList. For Part in PartList { If IgnoreTag = "" or (IgnoreTag  <> "" and Part:Tag <> IgnoreTag ) For Module in Part:Modules { If Module = "RealChuteModule" If Part:GetModule("RealChuteModule"):HasEvent("Cut Chute") = True Return True. If Module = "RealChuteFAR" If Part:GetModule("RealChuteFAR"):HasEvent("Cut Chute") = True Return True.  }} Return False.
  }
}

// .=============.
// | DRAW VECTOR |
// |=============|

Function DrawVector { Parameter StartVec is 0, EndVec is 0, Color is GREEN, Title is "Vector", Magnitude is 1, UpdateStartVec is False, UpdateEndVec is False.
  If StartVec = 0 Set StartVec to V(0,0,0). If EndVec = 0 Set EndVec to V(0,0,0). If Color = "" Set Color to GREEN.
  Set Vector to VecDraw(StartVec, EndVec, Color, Title, Magnitude, True).
  If UpdateStartVec = True Set Vector:StartUpdater to { Return StartVec.}.
  If UpdateEndVec = True Set Vector:VectorUpdater to { Return EndVec. }.
}

// .===================.
// | GEO-POSITION FROM |
// |===================|

Function GeoPositionFrom { Parameter GeoPos, cDistance, cBearing is Mod(360 - LatLng(90,0):Bearing, 360).
  Local Lat is ArcSin(Sin(GeoPos:Lat) * Cos((cDistance * 180) / (Body:Radius * Constant:PI)) + Cos(GeoPos:Lat) * Sin((cDistance * 180) / (Body:Radius * Constant:PI)) * Cos(cBearing)).
  Local Lng is 0. If ABS(Lat) <> 90 Local Lng is GeoPos:Lng + ArcTan2(Sin(cBearing) * Sin((cDistance * 180) / (Body:Radius * Constant:PI)) * Cos(GeoPos:Lat), Cos((cDistance * 180)/(Body:Radius * Constant:PI)) - Sin(GeoPos:Lat) * Sin(Lat)).
  Return LatLng(Lat, Lng).
}

// .=============.
// | GET HEADING |
// |=============|

Function GetHeading { Parameter cVector is Ship:SRFPrograde:Vector.
  Return MOD(ArcTan2(VDot(Heading(90, 0):Vector, cVector), VDot(Heading(0, 0):Vector, cVector)) + 360, 360).
}

// .==========.
// | SLOPE AT |
// |==========|

Function SlopeAt2 { Parameter GeoPos is Ship:GeoPosition, Distance is 1.
  Local NorthVec is VXCL((GeoPos:Position - GeoPos:Body:Position):Normalized, LATLNG(90, 0):Position - GeoPos:Position):Normalized * Distance.
  Local EastVec is VCRS((GeoPos:Position - GeoPos:Body:Position):Normalized, NorthVec):Normalized * Distance.
  Local aPos is GeoPos:Body:GeoPositionOf(GeoPos:Position - NorthVec + EastVec):Position - GeoPos:Position.
  Local bPos is GeoPos:Body:GeoPositionOf(GeoPos:Position - NorthVec - EastVec):Position - GeoPos:Position.
  Local cPos is GeoPos:Body:GeoPositionOf(GeoPos:Position + NorthVec):Position - GeoPos:Position.
  Return VANG((GeoPos:Position - GeoPos:Body:Position):Normalized, VCRS(aPos - cPos, bPos - cPos):Normalized).
}


// .==============.
// | GET RESOURCE |
// |==============|

  //Until False {
  //  Print GetResource("SolidFuel", "STAGE", "%", 2, True) + "   " at (0, 0).
  //  Print GetResource("LiquidFuel", "STAGE", "%", 4, True) + "   " at (0, 1).
  //  Print GetResource("LOX", "SHIP", "%", 2, True) + "   " at (0, 2).
  //  Print GetResource("LOX", "TopTank", "%", 2, True) + "   " at (0, 3).
  //  Print GetResource("LOX", "BottomTank", "%", 2, True) + "   " at (0, 4).
  //}

  // Return resource percent
  // cResource = { "LIQUIDFUEL", "OXIDIZER", "LOX", "SOLIDFUEL", "ELECTRICCHARGE", "MONOPROP", etc... }
  // cPart = { "SHIP", "STAGE", "'Part_Name'", "'Tag_Name'" }
  // cFormat = { "%", "TOTAL", "CURRENT", "DENSITY" }
  // cDecimal = { Number of decimals [Integer]}
  // cString =  { Return value in text format [TRUE or FALSE] }

Function GetResource {
  Parameter cResource is "LOX", cPart is "SHIP", cFormat is "%", cDecimal is 0, cString is False.  Local Total to 0. Local Current to 0. Local Density to 0.
  If cResource = "LOX" {
    Local cResLOX to "". If GetResource("LIQUIDFUEL", cPart, "%") <= GetResource("OXIDIZER", cPart, "%") { Set cResLOX to "LIQUIDFUEL". } Else { Set cResLOX to "OXIDIZER". }
    Return ConvertString(GetResource(cResLOX, cPart, cFormat, cDecimal, False), cDecimal, cString, cFormat).
  }
  If cPart = "SHIP" {
    For RES in Ship:Resources { If RES:Name = cResource { Set Total to RES:Capacity. Set Current to RES:Amount. Set Fuel to RES:Amount. Set Density to RES:Density. Break. }}
  } Else If cPart = "STAGE" {
    For RES in Stage:Resources { If RES:Name = cResource { Set Total to RES:Capacity. Set Current to RES:Amount. Set Density to RES:Density. Break. }}
  } Else {
    For Tank in Ship:PartsDubbed(cPart) { For RES in Tank:Resources { If RES:Name = cResource { Set Total to Total + RES:Capacity. Set Current to Current + RES:Amount. Set Density to Density + RES:Density. Break. }}}
  }
  If cFormat = "%" { If Current > 0 { Return ConvertString(Round((100 * Current) / Total, cDecimal), cDecimal, cString, cFormat). } Else { Return ConvertString(0, cDecimal, cString,  cFormat). }}
  If cFormat = "TOTAL" { Return ConvertString(Round(Total, cDecimal), cDecimal, cString). } If cFormat = "CURRENT" { Return ConvertString(Round(Current, cDecimal), cDecimal, cString). } If cFormat = "DENSITY" { Return ConvertString(Round(Density, cDecimal), cDecimal, cString). }
  Function ConvertString { Parameter cValue, cDecimal, cString, cFormat is "". If cString = False { Return cValue. } Else { Set cValue to cValue + "". }
    If cDecimal = 0 { Return cValue + cFormat. } Else {
      If cValue:Contains(".") = False {
        Return cValue + "." + "00000000000000000000":SubString(0, cDecimal) + cFormat.
      } Else {
        Return cValue + "0000000000":SubString(0, MAX(cDecimal - cValue:SubString(cValue:IndexOf(".") + 1, cValue:Length - (cValue:IndexOf(".") + 1)):Length, 0)) + cFormat.
      }
    }
    // Ignore Decouplers
  }
}

FUNCTION ground_track {	//returns the geocoordinates of the ship at a given time(UTs) adjusting for planetary rotation over time
	PARAMETER posTime.
	LOCAL pos IS POSITIONAT(SHIP,posTime).
	LOCAL localBody IS SHIP:BODY.
	LOCAL rotationalDir IS VDOT(localBody:NORTH:FOREVECTOR,localBody:ANGULARVEL). //the number of radians the body will rotate in one second (negative if rotating counter clockwise when viewed looking down on north
	LOCAL timeDif IS posTime - TIME:SECONDS.
	LOCAL posLATLNG IS localBody:GEOPOSITIONOF(pos).
	LOCAL longitudeShift IS rotationalDir * timeDif * CONSTANT:RADTODEG.
	LOCAL newLNG IS MOD(posLATLNG:LNG + longitudeShift ,360).
	IF newLNG < - 180 { SET newLNG TO newLNG + 360. }
	IF newLNG > 180 { SET newLNG TO newLNG - 360. }
	RETURN LATLNG(posLATLNG:LAT,newLNG).
}