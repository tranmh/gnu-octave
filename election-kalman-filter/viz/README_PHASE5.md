# Phase 5: Visualization - README

**Status**: ✅ COMPLETE  
**Date Completed**: October 19, 2025

---

## Overview

Phase 5 implements comprehensive visualization tools for the Kalman Filter Election Prediction System. The visualization suite provides seven distinct plotting functions that analyze and present prediction results, confidence intervals, polling data comparisons, and filter diagnostics.

---

## Files Implemented

| File | Purpose | Lines |
|------|---------|-------|
| `plot_prediction_timeline.m` | Main prediction timeline with uncertainty | ~128 |
| `plot_confidence_bands.m` | Multiple CI level visualization | ~99 |
| `plot_polls_vs_estimate.m` | Raw polls vs Kalman estimates | ~99 |
| `plot_transition_period.m` | Biden→Harris transition zoom | ~127 |
| `plot_final_comparison.m` | Prediction vs actual result | ~133 |
| `plot_diagnostics.m` | Filter diagnostics (uncertainty, innovation, gain) | ~127 |
| `generate_report.m` | Comprehensive report generator | ~165 |

**Total**: ~878 lines of visualization code

---

## Function Descriptions

### 1. plot_prediction_timeline()
**Purpose**: Main time series visualization of Democratic win probability over 52 weeks

**Features**:
- Blue prediction line with ±1σ uncertainty band
- 50% threshold reference line
- Actual election result overlay
- Biden→Harris transition marker (Week 38)
- Final metrics display (Brier score, grade)
- Custom date labels for key months

**Usage**:
```octave
results = run_backtest();
fig = plot_prediction_timeline(results, 'save_fig', true);
```

---

### 2. plot_confidence_bands()
**Purpose**: Multi-level confidence interval visualization

**Features**:
- Three CI levels: 68%, 95%, 99% (customizable)
- Layered shaded bands (lighter to darker)
- Z-score based interval calculation
- Automatic bound clipping to [0, 1]

**Usage**:
```octave
fig = plot_confidence_bands(results, 'ci_levels', [0.68, 0.95, 0.99]);
```

---

### 3. plot_polls_vs_estimate()
**Purpose**: Compare raw polling observations with Kalman filter estimates

**Features**:
- Kalman estimate line with uncertainty band
- Raw polling data as scatter points
- Logistic transformation of poll margins to win probability
- Poll count statistics in title

**Usage**:
```octave
polls = load('weekly_polls.mat');
fig = plot_polls_vs_estimate(results, polls);
```

---

### 4. plot_transition_period()
**Purpose**: Zoom into Biden→Harris candidate transition period

**Features**:
- Two subplots: prediction and uncertainty
- Configurable window (default: ±8 weeks from transition)
- Transition week marker (Week 38 = July 21, 2024)
- Uncertainty spike visualization

**Usage**:
```octave
fig = plot_transition_period(results, 'window', 10);
```

---

### 5. plot_final_comparison()
**Purpose**: Compare final prediction with actual election outcome

**Features**:
- Two subplots: win probability bars and vote share
- Side-by-side comparison (Prediction vs Actual)
- Error bars showing prediction uncertainty
- Color-coded by party (Blue=Dem, Red=Rep)
- Actual vote percentages (Trump 50.1%, Harris 48.3%)

**Usage**:
```octave
fig = plot_final_comparison(results);
```

---

### 6. plot_diagnostics()
**Purpose**: Kalman filter diagnostic plots for filter health analysis

**Features**:
- Three subplots:
  1. Prediction uncertainty evolution
  2. Innovation (measurement residuals)
  3. Kalman gain (filter responsiveness)
- Transition period markers on all subplots
- Graceful handling of missing diagnostic data

**Usage**:
```octave
fig = plot_diagnostics(results);
```

---

### 7. generate_report()
**Purpose**: Master function to generate all plots and save comprehensive report

**Features**:
- Generates all 6 individual plots automatically
- Optional combined report figure (3×2 grid)
- Timestamped filenames
- Automatic output directory creation
- Progress reporting with formatted output
- Configurable save and display options

**Usage**:
```octave
% Generate full report with all plots
polls = load('weekly_polls.mat');
generate_report(results, 'weekly_polls', polls, 'output_dir', './figures/');

% Generate without displaying (batch mode)
generate_report(results, 'show_plots', false);
```

---

## Common Parameters

All plotting functions support these optional parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title_text` | string | auto | Custom plot title |
| `save_fig` | logical | false | Save plot to PNG |
| `fig_name` | string | varies | Output filename |

---

## Usage Examples

### Example 1: Basic Visualization Workflow
```octave
% Step 1: Run backtest to get results
results = run_backtest();

% Step 2: Generate individual plots
fig1 = plot_prediction_timeline(results);
fig2 = plot_confidence_bands(results);
fig3 = plot_final_comparison(results);

% Step 3: Save specific plots
plot_transition_period(results, 'save_fig', true, 'fig_name', 'transition.png');
```

### Example 2: Complete Report Generation
```octave
% Load data
results = run_backtest();
polls = load('data/processed/weekly_polls.mat');

% Generate comprehensive report
generate_report(results, ...
                'weekly_polls', polls, ...
                'output_dir', './viz_output/', ...
                'save_individual', true, ...
                'save_combined', true, ...
                'show_plots', true);
```

### Example 3: Batch Mode (No Display)
```octave
% Generate all plots without displaying (for automation)
results = run_backtest();
generate_report(results, 'show_plots', false, 'output_dir', './batch_output/');
```

---

## Output Files

When using `generate_report()`, files are saved with timestamps:

```
viz_output/
├── 1_timeline_20251019_143022.png
├── 2_confidence_20251019_143022.png
├── 3_polls_vs_estimate_20251019_143022.png
├── 4_transition_20251019_143022.png
├── 5_final_comparison_20251019_143022.png
├── 6_diagnostics_20251019_143022.png
└── COMBINED_REPORT_20251019_143022.png
```

---

## Technical Specifications

### Figure Dimensions
- Individual plots: 1200×600 pixels (standard)
- Transition period: 1200×700 pixels (extra height for 2 subplots)
- Final comparison: 1000×600 pixels
- Diagnostics: 1200×800 pixels (3 subplots)
- Combined report: 1600×1200 pixels

### Color Scheme
- **Democratic**: Blue (RGB: 0.2, 0.4, 0.8)
- **Republican**: Red (RGB: 0.8, 0.2, 0.2)
- **Uncertainty bands**: Light blue with transparency
- **Reference lines**: Black dashed
- **Transition marker**: Green dashed (Week 38)

### Export Settings
- Format: PNG
- Resolution: 300 DPI (publication quality)
- Transparency: Supported via FaceAlpha

---

## Dependencies

### Required
- GNU Octave 10.3.0 (or compatible)
- Backtest results from Phase 4 (`run_backtest()`)
- Base graphics system (plot, fill, bar, etc.)

### Optional
- Weekly polling data (for `plot_polls_vs_estimate`)
- Innovation and Kalman gain history (for `plot_diagnostics`)

---

## Integration with Previous Phases

### Phase 4 Backtest Results
All visualization functions expect `backtest_results` struct with:
```octave
backtest_results:
  .predictions
    .weeks: [52×1] Week numbers
    .win_prob: [52×1] Win probabilities
    .win_prob_std: [52×1] Uncertainties
    .dates: {52×1} Date strings
    .innovation: [52×1] (optional)
    .kalman_gain: [52×1] (optional)
  .actual_outcome
    .winner: 'Trump' or 'Harris'
    .dem_vote_share: 48.3
    .rep_vote_share: 50.1
    .dem_margin: -1.8
  .metrics
    .final_prediction: scalar
    .brier_score: scalar
    .performance_grade: string
```

---

## Design Principles

1. **Clarity**: Clean, readable plots with clear labels
2. **Consistency**: Uniform color schemes and formatting
3. **Flexibility**: Customizable parameters for all functions
4. **Modularity**: Each function works independently
5. **Comprehensiveness**: `generate_report()` produces publication-ready figures

---

## Future Enhancements (Out of Scope)

- Interactive plots with zoom/pan capabilities
- Animation of prediction evolution
- State-by-state electoral college maps
- Comparison with other forecasting models
- Real-time updating visualization

---

## Troubleshooting

### Issue: Plots not displaying
**Solution**: Ensure Octave graphics toolkit is properly configured
```octave
graphics_toolkit  % Check current toolkit
available_graphics_toolkits  % See available options
```

### Issue: Figures not saving
**Solution**: Check write permissions for output directory
```octave
mkdir('./viz_output')  % Create directory manually
```

### Issue: Missing polling data
**Solution**: `plot_polls_vs_estimate()` requires weekly_polls struct. Skip if unavailable.

### Issue: Diagnostic plots empty
**Solution**: Innovation and gain data are optional. Plots show placeholders if missing.

---

## Testing

Visualization functions have been tested with:
- ✅ Backtest results from Phase 4
- ✅ Valid 52-week prediction data
- ✅ Various parameter combinations
- ✅ Save functionality (PNG export)
- ✅ Combined report generation

---

## Conclusion

Phase 5 provides a complete, production-ready visualization suite for the Kalman Filter Election Prediction System. All plots are publication-quality, customizable, and integrate seamlessly with Phase 4 backtesting results.

**Status**: ✅ COMPLETE AND READY FOR USE

---

*Phase 5 Documentation - Generated October 19, 2025*
