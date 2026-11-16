# 3D Print Cost — v1.0

[![Latest Release](https://img.shields.io/github/v/release/Mirozzo/3D-Print-Cost?label=version)](https://github.com/Mirozzo/3D-Print-Cost/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/Mirozzo/3D-Print-Cost/total?label=downloads)](https://github.com/Mirozzo/3D-Print-Cost/releases)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-blue)](https://github.com/Mirozzo/3D-Print-Cost/releases/latest)
[![License](https://img.shields.io/github/license/Mirozzo/3D-Print-Cost)](LICENSE)

A free 3D printing cost calculator for **Windows and Android**, with dedicated desktop and mobile interfaces.

3D Print Cost calculates **filament + electricity** cost and can save multiple build plates into the same Excel workbook to obtain the total cost of a complete 3D-printing project.

## Download — Version 1.0

| Platform | Download | Installation |
| --- | --- | --- |
| **Windows** | [3D_Print_Cost.exe](https://github.com/Mirozzo/3D-Print-Cost/releases/download/v1.0/3D_Print_Cost.exe) | Download and run the executable; Python is not required. |
| **Android** | [3D-Print-Cost-v1.0-Android.apk](https://github.com/Mirozzo/3D-Print-Cost/releases/download/v1.0/3D-Print-Cost-v1.0-Android.apk) | Download and open the APK on your Android device. Allow installation from this source if Android requests it. |

Both downloads are available in the [official v1.0 Release](https://github.com/Mirozzo/3D-Print-Cost/releases/tag/v1.0). The Android APK is distributed outside Google Play.

## Highlights

- 🇮🇹 Italian and 🇬🇧 English interfaces
- Modern dark desktop interface and redesigned touchscreen-friendly Android interface
- Main application opens maximized
- Local filament and price database
- Configurable electricity price (€/kWh)
- Configurable average printer consumption (W)
- Filament, energy and total-cost calculation
- Excel export
- Multi-plate project support with automatic object total
- Persistent local settings
- Standalone Windows executable and Android APK available through Releases
- Python source included

## Interface preview (Windows)

### Main dashboard

![3D Print Cost main dashboard](Screenshot/Home.png)

### Language selection

![3D Print Cost language selection](Screenshot/Choose%20language.png)

### Filament manager

![3D Print Cost filament manager](Screenshot/Manage%20filament.png)

### Electricity settings

![3D Print Cost electricity settings](Screenshot/Manage%20current.png)

## Quick start

### Windows executable

Download `3D_Print_Cost.exe` from the latest GitHub Release and run it.

The standalone executable does not require Python.

> The executable is not digitally signed. Microsoft Defender SmartScreen may display a warning for independently distributed applications.

### Android APK

Download `3D-Print-Cost-v1.0-Android.apk` from the Release and install it on an Android phone. No Python or Flutter installation is required. The Android version features a mobile-optimized dark interface, local filament management, adjustable electricity settings and Excel export with a location picker.

The APK is not distributed through Google Play. Install only from the official GitHub Release above.

### Python (Windows source)

Requirements: Python 3 and `openpyxl`.

```bash
pip install openpyxl
py 3D_Print_Cost.py
```

## How costs are calculated

```text
Filament cost = (grams / 1000) × filament price per kg
Estimated energy = (average Watts / 1000) × total print hours
Electricity cost = estimated kWh × electricity price per kWh
Total print cost = filament cost + electricity cost
```

The initial defaults are **€0.15/kWh** and **200 W**, and both can be changed.

## Multi-plate projects

Create an Excel workbook for the first plate. For subsequent plates, select the existing workbook to append additional rows. The Windows version includes a combined **Object Total**; the Android version lets you choose the destination for the updated Excel file.

## Local database

On Windows:

```text
%LOCALAPPDATA%\3D Print Cost\costi_stampa_3d.db
```

## Repository files

- `3D_Print_Cost.py` — original Windows application source
- `Windows/3D_Print_Cost.py` — Windows source copy on the Android development branch
- `Android/` — Flutter source on the `android-flutter-setup` development branch (not yet merged into `main`)
- `3D_Print_Cost.ico` — application icon
- `Screenshot/` — application interface screenshots
- `ISTRUZIONI_IT.txt` — detailed Italian guide
- `INSTRUCTIONS_EN.txt` — detailed English guide
- `LICENSE` — MIT License
- `.gitignore` — Git ignore rules

The compiled Windows `.exe` and Android `.apk` are distributed through **Releases**, not stored in the source repository. Android development currently lives in the [`android-flutter-setup` branch](https://github.com/Mirozzo/3D-Print-Cost/tree/android-flutter-setup).

## Accuracy

The electricity calculation is an estimate based on the configured average Watt value. A real energy meter provides a better input.

The app does not automatically include depreciation, maintenance, wear, labor, failed prints, taxes or profit margin.

## License

MIT License. See `LICENSE`.

---

If you find 3D Print Cost useful, consider starring the repository.
