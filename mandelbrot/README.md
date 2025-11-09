# Mandelbrot & Fractal Explorer

An elegant fractal visualization system in GNU Octave featuring multiple fractal types, interactive exploration, and stunning color palettes.

## ✨ Features

### 🎨 Beautiful Color Palettes (5)
- **Deep Ocean** 🌊 - Tranquil blues to white
- **Sunset Fire** 🔥 - Dramatic reds and oranges
- **Electric Dream** ⚡ - Psychedelic rainbow
- **Monochrome Elegance** 🎨 - Classic grayscale
- **Northern Lights** 🌌 - Mystical aurora colors

### 🔢 Fractal Types
**Implemented (Phase 1-3):**
- Mandelbrot Set
- Julia Sets

**Coming Soon (Phase 4-5):**
- Burning Ship
- Tricorn
- Multibrot
- Phoenix
- Perpendicular Mandelbrot
- 3D Mandelbulb
- 3D Mandelbox

### 🎮 Interactive Controls

**Mouse:**
- **Left Click** - Zoom in 2x at point
- **Right Click** - Zoom out 2x at point

**Keyboard:**
- **1-5** - Switch color palettes
- **M** - Mandelbrot set
- **J** - Julia set
- **+/-** - Increase/decrease iterations
- **Arrow Keys** - Pan view
- **R** - Reset to default view
- **H** - Show help
- **Q** - Quit

## 🚀 Quick Start

### Launch Interactive Explorer

```octave
cd('C:/Users/tranm/work/gnu-octave/mandelbrot')
fractal_explorer()
```

### Custom Resolution

```octave
fractal_explorer([1920, 1080])  % HD resolution
fractal_explorer([1280, 720])   % 720p
```

## 📸 Gallery Mode

View all 5 color palettes side-by-side:

```octave
cd('C:/Users/tranm/work/gnu-octave/mandelbrot')
addpath('core', 'display');
colormap_gallery();
```

## 🧪 Testing

Run phase tests:

```octave
cd tests
test_phase1  % Core algorithms
test_phase2  % Visualization
test_phase3  % Interactive controls
```

## 📁 Project Structure

```
mandelbrot/
├── README.md                     # This file
├── ImplementationPlan.md         # Detailed development plan
├── fractal_explorer.m            # Main interactive application
│
├── core/                         # Fractal algorithms
│   ├── mandelbrot_2d.m          # Mandelbrot set
│   ├── julia_2d.m               # Julia sets
│   ├── complex_grid.m           # Complex plane grid
│   └── escape_time_common.m     # Shared iteration logic
│
├── display/                      # Visualization
│   ├── smooth_coloring.m        # Continuous coloring
│   ├── create_palette.m         # Color palette generator
│   ├── apply_colormap.m         # RGB conversion
│   ├── init_fractal_window.m    # Window setup
│   ├── update_display.m         # Display refresh
│   └── colormap_gallery.m       # Palette comparison
│
├── interaction/                  # User controls
│   ├── handle_zoom.m            # Zoom logic
│   ├── handle_pan.m             # Pan navigation
│   └── handle_keyboard.m        # Keyboard handler
│
├── utils/                        # Utilities
│   ├── zoom_calculator.m        # Zoom calculations
│   └── coordinate_converter.m   # Screen ↔ complex plane
│
└── tests/                        # Test suites
    ├── test_phase1.m
    ├── test_phase2.m
    └── test_phase3.m
```

## 🎯 Performance

- **800×600**: < 1.5 seconds
- **1920×1080**: ~12 seconds (computation), 0.15s (coloring)
- **Smooth coloring**: Eliminates banding
- **Optimized**: Vectorized operations throughout

## 📊 Current Status

| Phase | Status | Description |
|-------|--------|-------------|
| **Phase 1** | ✅ COMPLETE | Core 2D fractals |
| **Phase 2** | ✅ COMPLETE | Visualization & palettes |
| **Phase 3** | ✅ COMPLETE | Interactive explorer |
| **Phase 4** | ⏳ TODO | Extended 2D fractals |
| **Phase 5** | ⏳ TODO | 3D fractals |
| **Phase 6** | ⏳ TODO | Export & advanced features |

## 🎨 Color Palette Details

### 1. Deep Ocean 🌊
Inspired by ocean depths to sunlit surface. Deep blues transition through cyan to white.

### 2. Sunset Fire 🔥
Black through deep red, orange, yellow to white. High contrast, warm tones.

### 3. Electric Dream ⚡
Psychedelic journey through purple, magenta, cyan, green, yellow. Maximum color variation.

### 4. Monochrome Elegance 🎨
Pure grayscale for structural clarity. Black through gray to white.

### 5. Northern Lights 🌌
Aurora borealis inspired. Dark blue through green, light blue, to pink.

## 🔬 Technical Details

### Smooth Coloring Algorithm
Uses the formula:
```
mu = n + 1 - log(log(|z_n|)) / log(2)
```
This provides continuous iteration values, eliminating color banding.

### Mandelbrot Set
```
z_0 = 0
z_{n+1} = z_n^2 + c
```
Points where |z| remains bounded are in the set (colored black).

### Julia Sets
```
z_{n+1} = z_n^2 + c (fixed c)
```
Classic Julia parameter: c = -0.7 + 0.27i

## 🎓 Requirements

- **GNU Octave** 10.3.0 or later
- No additional packages required
- Graphics capability (for visualization)

## 🐛 Troubleshooting

### Graphics Warning
If you see FLTK warnings, they're safe to ignore or switch toolkit:
```octave
graphics_toolkit('qt')  % If available
```

### Slow Performance
- Reduce resolution: `fractal_explorer([640, 480])`
- Decrease iterations with `-` key
- Use monochrome palette for fastest coloring

### Click Not Responding
- Ensure window has focus
- Click within the image area
- Check that window is active

## 📖 Examples

### Explore Seahorse Valley
```octave
fractal_explorer()
% Click near coordinates (-0.745, 0.113)
% Zoom in repeatedly to see seahorse shapes
% Switch palettes with 1-5 keys
```

### Julia Set Variations
```octave
fractal_explorer()
% Press J for Julia set
% Try different zoom levels
% Press 3 for Electric Dream palette
```

## 🚧 Coming Soon

**Phase 4 (Extended 2D Fractals):**
- Burning Ship
- Tricorn
- Multibrot (power variants)
- Phoenix
- Additional fractal types

**Phase 5 (3D Fractals):**
- Mandelbulb with ray marching
- Mandelbox visualization
- Interactive 3D rotation

**Phase 6 (Advanced Features):**
- Pattern library (famous locations)
- Bookmark system
- 4K image export
- Deep zoom animations
- Batch rendering

## 💡 Tips

- Start with default Mandelbrot view to orient yourself
- Use **+** key to increase detail in zoomed areas
- Try all 5 palettes on the same location
- **R** key resets if you get lost
- Arrow keys for fine position adjustments

## 🎬 Demo

Run the Phase 2 demo to see all palettes:
```octave
cd mandelbrot
demo_phase2
```

---

**Version**: Phase 3 Complete
**Created**: November 2025
**Platform**: GNU Octave 10.3.0

*Explore the infinite beauty of mathematics!* ✨🔢
