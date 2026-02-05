
<div align="center">

![WIP](https://img.shields.io/badge/work%20in%20progress-yellow?style=for-the-badge)
![KerboScript](https://img.shields.io/badge/Kerbo%20Script-brown?style=for-the-badge)
![kOS](https://img.shields.io/badge/kOS-Autopilot-blue?style=for-the-badge)
![KSP](https://img.shields.io/badge/Kerbal-Space%20Program-orange?style=for-the-badge)


*Script de aterrizaje asistido a plataformas*

</div>

<div align="center">
  <img src="/Go2Pad.png">
</div>

# Go2Pad

[README en Español](README_es.md)

`Go2Pad` is a precision landing helper for `Kerbal Space Program` (KSP) written in `kOS` (Kerbal Operating System). It lets you pick a landing pad, target, waypoint, or coordinates and guides the craft to a controlled hover and touchdown using `Trajectories` impact prediction.

`NOTES`: This README is only a template and does not represent the current state of the project. It is also not finished.

## ✨ Features

- `Pad Selection`: Built-in pads, custom pads, targets, and waypoints
- `Precision Guidance`: PID-based steering to hold the pad and correct drift
- `Auto-Slope`: Optional slope scanning to find a safe nearby spot
- `Offset Landing`: Shift the landing point by meters for fine placement
- `Live Telemetry`: Terrain altitude, distance, slope, fuel, and battery
- `Landing Anywhere`: Switch to a free landing spot while flying

## 🖥️ Requirements

- `Kerbal Space Program` with `kOS mod` installed
- `Trajectories mod` (for accurate impact prediction)

## 🔧 Installation

1. Install kOS mod for Kerbal Space Program
2. Install Trajectories mod
3. Clone or download this repository
4. Copy all `.ks` files to your KSP `Ships/Script` folder or load them onto your craft's kOS processor

## 🎮 Usage

### Basic Usage

```kerboscript
run GoToPad.
```

### Select a Pad or Coordinates

```kerboscript
run GoToPad("LaunchPad").
run GoToPad("-0.097207, -74.557672").
```

### Add Custom Pads

```kerboscript
run AddPad.
run AddPad("Current").
run AddPad("Target").
run AddPad("MyPad", -0.097207, -74.557672).
```

### Interactive Controls

- `Left/Right Arrow Keys`: Cycle through pads
- `P`: Toggle auto-slope
- `O` / `Shift+O`: Offset the landing point
- `S`: Show settings panel
- `L`: Switch to land anywhere (when flying)
- `Enter`: Start guidance

## ⚙️ Configuration

### Custom Pad List

Pads are stored in `Pads.ks` as triplets: name, coordinates, body name.

```kerboscript
cPads:Add("My Custom Pad").
cPads:Add("12.345678, -98.765432").
cPads:Add("Kerbin").
```

## 📚 Troubleshooting

### Trajectories Not Found
- Ensure the Trajectories mod is installed and active
- The script exits if Trajectories is not available

### No Pads Shown
- Land closer to the target area or reduce speed and altitude
- Add a custom pad with `AddPad`

## 📄 License

This project is licensed under the WTFPL – [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

---

<div align="center">

**🚀 Desarrollado por Kobayashi82 🚀**

*"Navigation by controlled falling"*

</div>
