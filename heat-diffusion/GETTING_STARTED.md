# Getting Started with Heat Diffusion Simulator

## 🚀 Quick Start (3 Steps)

### Step 1: Open GNU Octave
Launch GNU Octave from:
```
C:\Users\tranm\AppData\Local\Programs\GNU Octave\Octave-10.3.0
```

### Step 2: Navigate to Project
```octave
cd('C:/Users/tranm/work/gnu-octave/heat-diffusion')
```

### Step 3: Run Simulation
```octave
main_1d    % For 1D heat diffusion
% OR
main_2d    % For 2D heat diffusion
```

That's it! Follow the on-screen prompts to select a pattern and watch heat diffuse.

---

## 🎮 Interactive Controls

**During simulation, use these keys:**

| Key | Action |
|-----|--------|
| `SPACE` | Pause/Resume simulation |
| `UP` | Speed up (reduce delay) |
| `DOWN` | Slow down (increase delay) |
| `R` | Reset to initial condition |
| `Q` | Quit simulation |
| `H` | Show help overlay |
| `V` | Change view mode (2D only) |

---

## 🎨 Available Patterns

### 1D Patterns (5 options)
1. **Gaussian** - Smooth bell curve
2. **Step** - Sharp temperature jump
3. **Double Peak** - Two separated peaks
4. **Sine** - Sinusoidal wave
5. **Random** - Random temperature field

### 2D Patterns (7 options)
1. **Center Hot** - Hot spot at center
2. **Corner Hot** - Hot corners
3. **Gaussian** - 2D bell curve
4. **Ring** - Hot ring structure
5. **Checkerboard** - Alternating pattern
6. **Radial** - Radial gradient
7. **Random** - Random 2D field

---

## 📊 What You'll See

### 1D Simulation
- Real-time line plot showing temperature vs. position
- Watch how heat spreads from hot regions to cold
- See sharp peaks smooth out over time

### 2D Simulation
- 3D surface plot, heatmap, or contour view
- Watch 2D heat diffusion in real-time
- Press `V` to cycle through visualization modes

---

## 🧪 Running Tests

To verify everything works correctly:

```octave
cd('C:/Users/tranm/work/gnu-octave/heat-diffusion')
test_phase5
```

**Expected result**: All 14 tests pass ✓

---

## 📚 Learn More

### Documentation Files
- **README.md** - Comprehensive project guide
- **PROJECT_SUMMARY.md** - High-level overview
- **QUICK_REFERENCE.md** - Command reference
- **ImplementationPlan.md** - Detailed technical plan
- **FINAL_COMPLETION_REPORT.md** - Complete project report

### What's Happening Mathematically
The simulator solves the **Heat Equation**:

```
∂u/∂t = α ∇²u
```

Where:
- `u` = temperature at each point
- `α` = thermal diffusivity (how fast heat spreads)
- `∇²` = Laplacian (measures temperature curvature)

**Physical meaning**: Heat flows from hot to cold regions.

---

## 🎯 Try These Examples

### Example 1: Watch a Gaussian Diffuse
```octave
main_1d
% Select: 1 (Gaussian)
```
**What to observe**: The peak decreases and widens as heat spreads.

### Example 2: Sharp Interface Smoothing
```octave
main_1d
% Select: 2 (Step)
```
**What to observe**: Sharp boundary smooths out gradually.

### Example 3: 2D Ring Pattern
```octave
main_2d
% Select: 4 (Ring)
```
**What to observe**: Heat flows both inward and outward from the ring.

### Example 4: Compare View Modes
```octave
main_2d
% Select any pattern
% Press V repeatedly to cycle through: Surface → Heatmap → Contour
```
**What to observe**: Different views show different aspects of the temperature field.

---

## ⚙️ Customizing Parameters

Want to experiment? Edit parameters in `main_1d.m` or `main_2d.m`:

```octave
% Physical parameters
params.alpha = 0.01;        % Thermal diffusivity (try 0.005 or 0.02)
params.dt = 0.001;          % Time step (smaller = more accurate)
params.t_final = 1.0;       % How long to simulate

% Grid resolution
params.nx = 100;            % More points = smoother (but slower)
```

After editing, save and run `main_1d` or `main_2d` again.

---

## 🐛 Troubleshooting

### Problem: Simulation runs too fast
**Solution**: Press `DOWN` key during simulation to slow down

### Problem: Simulation runs too slow
**Solution 1**: Press `UP` key to speed up
**Solution 2**: Reduce grid size (decrease `nx` or `ny`)

### Problem: Error about missing functions
**Solution**: Make sure you're in the project directory:
```octave
cd('C:/Users/tranm/work/gnu-octave/heat-diffusion')
```

### Problem: Visualization looks pixelated
**Solution**: Increase grid resolution in the main file:
```octave
params.nx = 200;  % for 1D
% or
params.nx = 100; params.ny = 100;  % for 2D
```

---

## 💡 Tips for Best Experience

1. **Start with 1D**: It's faster and easier to understand
2. **Try all patterns**: Each shows different physics
3. **Use controls**: Pause to examine details, speed up for quick overview
4. **Experiment**: Change parameters and see what happens
5. **Read help**: Press `H` during simulation for control reference

---

## 🎓 Educational Use

### For Students
- See how heat diffusion works in real-time
- Understand numerical methods for PDEs
- Learn about stability and accuracy

### For Teachers
- Classroom demonstrations
- Interactive physics/math lessons
- Numerical methods examples

### For Researchers
- Algorithm development
- Method comparison
- Parameter studies

---

## 📞 Need Help?

1. **Check documentation**: See README.md for details
2. **Run tests**: `test_phase5` verifies everything works
3. **Review examples**: See files in `tests/` directory
4. **Read code comments**: All functions are well-documented

---

## ✅ Checklist for First Run

- [ ] GNU Octave installed and working
- [ ] Navigated to project directory
- [ ] Ran `main_1d` or `main_2d`
- [ ] Selected a pattern
- [ ] Watched the simulation
- [ ] Tried the interactive controls
- [ ] Experimented with different patterns
- [ ] Ran tests with `test_phase5`

**Once you've done all these, you're ready to explore!** 🎉

---

## 🚀 Next Steps

After getting comfortable with the basics:

1. **Modify parameters** to see effects on diffusion
2. **Try all patterns** to understand different behaviors
3. **Read the math** in ImplementationPlan.md
4. **Explore the code** to learn implementation details
5. **Run benchmarks** to understand performance

---

**Ready? Let's go!**

```octave
cd('C:/Users/tranm/work/gnu-octave/heat-diffusion')
main_1d
```

Enjoy exploring heat diffusion! 🔥➡️❄️
