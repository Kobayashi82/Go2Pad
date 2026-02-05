// .============.
// | CONSTANTS |
// |============|

// Constant values
@LAZYGLOBAL OFF.
DECLARE PARAMETER BODY_RADIUS, BODY_MU, BODY_ROTATIONAL_PERIOD.
SET BODY_RADIUS TO Ship:BODY:RADIUS.
SET BODY_MU TO Ship:BODY:MU.
SET BODY_ROTATIONAL_PERIOD TO Ship:BODY:ROTATIONPERIOD.

// .==========.
// | HEADING |
// |==========|

// Function to get heading vector
FUNCTION Heading {
  PARAMETER HeadingDeg, PitchDeg.
  LOCAL HeadRad TO HeadingDeg * (CONSTANT():DEGTORAD).
  LOCAL PitchRad TO PitchDeg * (CONSTANT():DEGTORAD).
  RETURN V(0, SIN(PitchRad), COS(PitchRad)) * R(0, 0, 1, HeadRad).
}

// .============.
// | LATLNGBOX |
// |============|

// Function to create a LatLngBox
FUNCTION LatLngBox {
  PARAMETER Center, Size.
  LOCAL HalfSize TO Size / 2.
  LOCAL NorthWest TO GeoPositionFrom(Center, HalfSize, 315).
  LOCAL SouthEast TO GeoPositionFrom(Center, HalfSize, 135).
  RETURN List(NorthWest, SouthEast).
}
// .=================.
// | LATLNG DISTANCE |
// |=================|

// Function to calculate distance between two LatLng coordinates
FUNCTION LatLngDistance {
  PARAMETER LatLng1, LatLng2.
  LOCAL dLat TO (LatLng2:LAT - LatLng1:LAT) * (CONSTANT():DEGTORAD).
  LOCAL dLng TO (LatLng2:LNG - LatLng1:LNG) * (CONSTANT():DEGTORAD).
  LOCAL a TO SIN(dLat / 2)^2 + COS(LatLng1:LAT * CONSTANT():DEGTORAD) * COS(LatLng2:LAT * CONSTANT():DEGTORAD) * SIN(dLng / 2)^2.
  LOCAL c TO 2 * ATAN2(SQRT(a), SQRT(1 - a)).
  RETURN BODY_RADIUS * c.
}

// .=================.
// | LATLNG BEARING |
// |=================|

// Function to calculate initial bearing between two LatLng coordinates
FUNCTION LatLngBearing {
  PARAMETER LatLng1, LatLng2.
  LOCAL dLng TO (LatLng2:LNG - LatLng1:LNG) * (CONSTANT():DEGTORAD).
  LOCAL y TO SIN(dLng) * COS(LatLng2:LAT * CONSTANT():DEGTORAD).
  LOCAL x TO COS(LatLng1:LAT * CONSTANT():DEGTORAD) * SIN(LatLng2:LAT * CONSTANT():DEGTORAD) - SIN(LatLng1:LAT * CONSTANT():DEGTORAD) * COS(LatLng2:LAT * CONSTANT():DEGTORAD) * COS(dLng).
  RETURN MOD(ATAN2(y, x) * (CONSTANT():RADTODEG) + 360, 360).
}

// .======================.
// | LATLNG DESTINATION |
// |======================|

// Function to calculate destination LatLng given a starting LatLng, distance, and bearing
FUNCTION LatLngDestination {
  PARAMETER LatLng1, Distance, Bearing.
  LOCAL AngularDistance TO Distance / BODY_RADIUS.
  LOCAL BearingRad TO Bearing * (CONSTANT():DEGTORAD).
  LOCAL Lat1Rad TO LatLng1:LAT * (CONSTANT():DEGTORAD).
  LOCAL Lng1Rad TO LatLng1:LNG * (CONSTANT():DEGTORAD).

  LOCAL Lat2Rad TO ASIN(SIN(Lat1Rad) * COS(AngularDistance) + COS(Lat1Rad) * SIN(AngularDistance) * COS(BearingRad)).
  LOCAL Lng2Rad TO Lng1Rad + ATAN2(SIN(BearingRad) * SIN(AngularDistance) * COS(Lat1Rad), COS(AngularDistance) - SIN(Lat1Rad) * SIN(Lat2Rad)).
  RETURN LATLNG(Lat2Rad * (CONSTANT():RADTODEG), Lng2Rad * (CONSTANT():RADTODEG)).
}
// .=======================.
// | GET SURFACE ALTITUDE |
// |=======================|

// Function to get the terrain height at a specific geo coordinate
FUNCTION GetSurfaceAltitude {
  PARAMETER GeoPos.
  LOCAL radiusAtGeoPos TO SHIP:BODY:GEOPOSITIONOF(GeoPos):POSITION:MAG.
  RETURN radiusAtGeoPos - SHIP:BODY:RADIUS.
}

// .====================.
// | GET SURFACE NORMAL |
// |====================|

// Function to get the surface normal vector at a specific geo coordinate
FUNCTION GetSurfaceNormal {
  PARAMETER GeoPos.
  RETURN (GeoPos:POSITION - SHIP:BODY:POSITION):NORMALIZED.
}

// .=======================.
// | GET SURFACE SLOPE |
// |=======================|

// Function to get the surface slope angle at a specific geo coordinate
FUNCTION GetSurfaceSlope {
  PARAMETER GeoPos, Distance IS 1.
  LOCAL NorthVec TO VXCL((GeoPos:POSITION - GeoPos:BODY:POSITION):NORMALIZED, LATLNG(90, 0):POSITION - GeoPos:POSITION):NORMALIZED * Distance.
  LOCAL EastVec TO VCRS((GeoPos:POSITION - GeoPos:BODY:POSITION):NORMALIZED, NorthVec):NORMALIZED * Distance.
  LOCAL aPos TO GeoPos:BODY:GEOPOSITIONOF(GeoPos:POSITION - NorthVec + EastVec):POSITION - GeoPos:POSITION.
  LOCAL bPos TO GeoPos:BODY:GEOPOSITIONOF(GeoPos:POSITION - NorthVec - EastVec):POSITION - GeoPos:POSITION.
  LOCAL cPos TO GeoPos:BODY:GEOPOSITIONOF(GeoPos:POSITION + NorthVec):POSITION - GeoPos:POSITION.
  RETURN VANG((GeoPos:POSITION - GeoPos:BODY:POSITION):NORMALIZED, VCRS(aPos - cPos, bPos - cPos):NORMALIZED).
}
// .================.
// | GET ANGLE OF   |
// | ATTACK         |
// |================|

FUNCTION GetAoA {
  PARAMETER cVector IS SHIP:SRFPROGRADE:VECTOR.
  RETURN VANG( cVector, SHIP:VELOCITY:SURFACE ) * SHIP:FACING:TOPVECTOR:Z.
}

// .================.
// | GET DRAG COEF  |
// |================|

FUNCTION GetDragCoef {
  PARAMETER cSpeed IS SHIP:VELOCITY:SURFACE:MAG.
  LOCAL aSpeed TO 0. LOCAL bSpeed TO 0. LOCAL cSpeed TO 0.
  IF SHIP:BODY = BODY("KERBIN") { SET aSpeed TO 100. SET bSpeed TO 300. SET cSpeed TO 600. }
  IF SHIP:BODY = BODY("DUNA") { SET aSpeed TO 70. SET bSpeed TO 200. SET cSpeed TO 400. }
  IF SHIP:BODY = BODY("LAYTHE") { SET aSpeed TO 50. SET bSpeed TO 150. SET cSpeed TO 300. }
  IF cSpeed > 0 {
    IF cSpeed >= cSpeed { RETURN 0. }
    IF cSpeed >= bSpeed { RETURN 0.5 + 0.5 * ((cSpeed - bSpeed) / (cSpeed - bSpeed)) }
    IF cSpeed >= aSpeed { RETURN 1 - 0.5 * ((cSpeed - aSpeed) / (bSpeed - aSpeed)) }
  }
  RETURN 1.
}

// .================.
// | GET LIFT COEF  |
// |================|

FUNCTION GetLiftCoef {
  PARAMETER cAoA IS GetAoA().
  LOCAL aAoA TO 0. LOCAL bAoA TO 0. LOCAL cAoA TO 0.
  IF SHIP:BODY = BODY("KERBIN") { SET aAoA TO 18. SET bAoA TO 14. SET cAoA TO 50. }
  IF SHIP:BODY = BODY("DUNA") { SET aAoA TO 14. SET bAoA TO 10. SET cAoA TO 35. }
  IF SHIP:BODY = BODY("LAYTHE") { SET aAoA TO 10. SET bAoA TO 7. SET cAoA TO 25. }
  IF cAoA > 0 {
    IF cAoA >= cAoA { RETURN 0. }
    IF cAoA >= bAoA { RETURN 0.5 + 0.5 * ((cAoA - bAoA) / (cAoA - bAoA)) }
    IF cAoA >= aAoA { RETURN 1 - 0.5 * ((cAoA - aAoA) / (bAoA - aAoA)) }
  }
  RETURN 1.
}
// .=============.
// | DRAW VECTOR |
// |=============|

FUNCTION DrawVector {
  PARAMETER StartVec IS V(0,0,0), EndVec IS V(0,0,0), Color IS GREEN, Title IS "Vector", Magnitude IS 1, UpdateStartVec IS FALSE, UpdateEndVec IS FALSE.
  SET Vector TO VECDRAW(StartVec, EndVec, Color, Title, Magnitude, TRUE).
  IF UpdateStartVec SET Vector:STARTUPDATER TO { RETURN StartVec. }.
  IF UpdateEndVec SET Vector:VECTORUPDATER TO { RETURN EndVec. }.
}

// .===================.
// | GEO-POSITION FROM |
// |===================|

FUNCTION GeoPositionFrom {
  PARAMETER GeoPos, cDistance, cBearing IS MOD(360 - LATLNG(90, 0):BEARING, 360).
  LOCAL Lat IS ARCSIN(SIN(GeoPos:LAT) * COS((cDistance * 180) / (BODY:RADIUS * CONSTANT:PI)) + COS(GeoPos:LAT) * SIN((cDistance * 180) / (BODY:RADIUS * CONSTANT:PI)) * COS(cBearing)).
  LOCAL Lng IS 0.
  IF ABS(Lat) <> 90 SET Lng TO GeoPos:LNG + ARCTAN2(SIN(cBearing) * SIN((cDistance * 180) / (BODY:RADIUS * CONSTANT:PI)) * COS(GeoPos:LAT), COS((cDistance * 180) / (BODY:RADIUS * CONSTANT:PI)) - SIN(GeoPos:LAT) * SIN(Lat)).
  RETURN LATLNG(Lat, Lng).
}

// .=============.
// | GET HEADING |
// |=============|

FUNCTION GetHeading {
  PARAMETER cVector IS SHIP:SRFPROGRADE:VECTOR.
  RETURN MOD(ARCTAN2(VDOT(HEADING(90, 0):VECTOR, cVector), VDOT(HEADING(0, 0):VECTOR, cVector)) + 360, 360).
}

// .==========.
// | SLOPE AT |
// |==========|

FUNCTION SlopeAt2 {
  PARAMETER GeoPos IS SHIP:GEOPOSITION, Distance IS 1.
  LOCAL NorthVec IS VXCL((GeoPos:POSITION - GeoPos:BODY:POSITION):NORMALIZED, LATLNG(90, 0):POSITION - GeoPos:POSITION):NORMALIZED * Distance.
  LOCAL EastVec IS VCRS((GeoPos:POSITION - GeoPos:BODY:POSITION):NORMALIZED, NorthVec):NORMALIZED * Distance.
  LOCAL aPos IS GeoPos:BODY:GEOPOSITIONOF(GeoPos:POSITION - NorthVec + EastVec):POSITION - GeoPos:POSITION.
  LOCAL bPos IS GeoPos:BODY:GEOPOSITIONOF(GeoPos:POSITION - NorthVec - EastVec):POSITION - GeoPos:POSITION.
  LOCAL cPos IS GeoPos:BODY:GEOPOSITIONOF(GeoPos:POSITION + NorthVec):POSITION - GeoPos:POSITION.
  RETURN VANG((GeoPos:POSITION - GeoPos:BODY:POSITION):NORMALIZED, VCRS(aPos - cPos, bPos - cPos):NORMALIZED).
}
