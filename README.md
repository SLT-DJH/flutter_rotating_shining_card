# flutter_rotating_shining_card

![Preview](https://raw.githubusercontent.com/SLT-DJH/flutter_rotating_shining_card/main/example/assets/images/preview.gif)

A Flutter widget that displays a 3D rotating card with realistic light reflection effects, including specular highlight, fresnel edge glow, and rainbow shimmer.

## Features

- 🔄 3D card flip with pan gesture
- ✨ Ambient light from top-left with tilt response  
- 💡 Specular highlight based on tilt angle
- 🌟 Fresnel edge glow effect
- 🌈 Rainbow shimmer overlay
- 👆 Multi-layer radial touch shine
- 🎯 Snap animation on release

## Installation

```yaml
dependencies:
  flutter_rotating_shining_card: ^1.0.0
```

## Usage

```dart
import 'package:flutter_rotating_shining_card/flutter_rotating_shining_card.dart';

RotatingShiningCard(
  width: 240,
  height: 340,
  frontChild: Image.asset('assets/front.png', fit: BoxFit.cover),
  backChild: Image.asset('assets/back.png', fit: BoxFit.cover),
  borderRadius: 16.0,
  shineIntensity: 0.6,
  shineColor: Colors.white,
)
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `frontChild` | `Widget` | required | Front face widget |
| `backChild` | `Widget` | required | Back face widget |
| `width` | `double` | required | Card width |
| `height` | `double` | required | Card height |
| `borderRadius` | `double` | `8.0` | Corner radius |
| `shineIntensity` | `double` | `0.5` | Light intensity (0.0~1.0) |
| `shineColor` | `Color` | `Colors.white` | Shine color |

## Credits

Inspired by [rotating_shining_card](https://pub.dev/packages/rotating_shining_card) by [Hassan Zafar](https://github.com/hassan-zafar/360_rotating_shining_card).  
This package extends the original with improved light reflection, specular highlight, fresnel edge glow, rainbow shimmer, and bug fixes.
