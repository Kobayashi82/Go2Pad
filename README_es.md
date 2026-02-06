
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

[README in English](README.md)

`Go2Pad` es un asistente de aterrizaje de precision para `Kerbal Space Program` (KSP) escrito en `kOS` (Kerbal Operating System). Permite elegir una plataforma, objetivo, waypoint o coordenadas y guia la nave hasta un hover y aterrizaje controlado usando la prediccion de impacto de `Trajectories`.

`NOTAS`: Este README es solo una plantilla y no representa el estado actual del proyecto. Además, no está terminado.

## ✨ Caracteristicas

- `Seleccion de plataforma`: Plataformas integradas, personalizadas, objetivos y waypoints
- `Guiado preciso`: Direccionamiento con PID para mantener el punto
- `Auto-Slope`: Opcional para buscar pendiente segura cerca del punto
- `Offset de aterrizaje`: Desplaza el punto en metros para ajuste fino
- `Telemetria en vivo`: Altitud de terreno, distancia, pendiente, combustible y bateria
- `Aterrizaje en cualquier lugar`: Cambia a un punto libre en vuelo

## 🖥️ Requisitos

- `Kerbal Space Program` con `mod kOS` instalado
- `Mod Trajectories` (para predicción precisa de impacto)

## 🔧 Instalacion

1. Instala el mod `kOS` para Kerbal Space Program
2. Instala el mod `Trajectories`
3. Clona o descarga este repositorio
4. Copia todos los archivos `.ks` a tu carpeta `Ships/Script` de KSP o cargalos en el procesador kOS de tu nave

## 🎮 Uso

```kerboscript
run go2pad.
```

### Elegir plataforma o coordenadas

```kerboscript
run go2pad("LaunchPad").
run go2pad("-0.097207, -74.557672").
```

### Agregar plataformas personalizadas

```kerboscript
run addpad.
run addpad("Current").
run addpad("Target").
run addpad("MyPad", -0.097207, -74.557672).
```

### Controles interactivos

- `Flechas Izquierda/Derecha`: Cambiar entre plataformas
- `P`: Alternar auto-slope
- `O` / `Shift+O`: Ajustar offset de aterrizaje
- `S`: Mostrar panel de ajustes
- `L`: Aterrizar en cualquier lugar (en vuelo)
- `Enter`: Iniciar guiado

## ⚙️ Configuracion

### Lista de plataformas personalizadas

Las plataformas se guardan en `Pads.ks` como tripletas: nombre, coordenadas, cuerpo.

```kerboscript
cPads:Add("My Custom Pad").
cPads:Add("12.345678, -98.765432").
cPads:Add("Kerbin").
```

## 📚 Solucion de problemas

### Trajectories no encontrado
- Asegurate de que el mod `Trajectories` este instalado y activo
- El script se cierra si `Trajectories` no esta disponible

### No aparecen plataformas
- Aterriza mas cerca o reduce velocidad y altitud
- Agrega una plataforma con `addpad`

## 📄 Licencia

Este proyecto esta licenciado bajo la WTFPL – [Do What the Fuck You Want to Public License](http://www.wtfpl.net/about/).

---

<div align="center">

**🚀 Desarrollado por Kobayashi82 🚀**

*"Navigation by controlled falling"*

</div>
