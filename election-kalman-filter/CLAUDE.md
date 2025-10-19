# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GNU Octave-based Kalman filter implementation for predicting the 2024 US Presidential election outcome using polling data. The system processes 52 weeks of polling data (Nov 5, 2023 to Nov 5, 2024) through a mathematically rigorous Kalman filter to estimate win probabilities.

GNU Octave Installation can be found at:
C:\Users\tranm\AppData\Local\Programs\GNU Octave\Octave-10.3.0

## Development Commands

### Running the Complete Pipeline
```octave
% Full execution from data to visualization
cd data && download_data() && parse_polls() && aggregate_weekly()
cd ../pipeline && weekly_processor()
cd ../backtest && run_backtest()
cd ../viz && generate_report()
```

### Running Individual Phases
```octave
% Phase 1: Data Processing
cd data
poll_data = parse_polls();           % Parse FiveThirtyEight polls
weekly_data = aggregate_weekly();    % Create 52-week aggregation

% Phase 2-3: Kalman Filtering
cd pipeline
results = weekly_processor();        % Run full 52-week Kalman filter

% Phase 4: Backtesting
cd backtest
metrics = run_backtest();           % Validate against actual results

% Phase 5: Visualization
cd viz
plot_prediction_timeline();         % Main time series plot
plot_confidence_bands();           % Uncertainty visualization
```

### Running Tests
```octave
% Run all tests for a specific phase
cd tests
test_data_processing()    % Phase 1 tests
test_kalman_core()       % Phase 2 tests
test_pipeline()          % Phase 3 tests
test_backtest()          % Phase 4 tests
test_tuning()            % Phase 6 tests

% CLI test runners (for automated testing)
test_data_processing_cli()
test_tuning_cli()
```

### Running Individual Functions
```octave
% Test with specific parameters
cd core
[x_pred, P_pred] = kalman_predict(x, P, F, Q);
[x_new, P_new, K, innovation] = kalman_update(x_pred, P_pred, z, H, R);

% Process specific week
cd pipeline
prob = polls_to_probability(dem_pct, rep_pct);
```

## Architecture & Design

### Core Kalman Filter Model
The system models election dynamics using a scalar Kalman filter where:
- **State (x)**: Democratic candidate's win probability [0,1]
- **Measurement (z)**: Poll-derived win probability
- **Process noise (Q)**: Campaign dynamics uncertainty (default: 0.001, increases 5x during Biden→Harris transition)
- **Measurement noise (R)**: Polling uncertainty (default: 0.05)

### Processing Pipeline Architecture
```
Raw Polls → Parse & Filter → Weekly Aggregation → Kalman Filter → Backtest → Visualize
   ↓              ↓                ↓                    ↓             ↓          ↓
CSV data    Trump/Biden    52-week means      State estimates  Metrics   PNG plots
           Trump/Harris                         & uncertainty   & CIs     & report
```

### Key Design Decisions

1. **Candidate Transition Handling**: The system automatically detects and handles the Biden→Harris transition at Week 38 (July 21, 2024) by:
   - Increasing process noise Q by 5x for 3 weeks
   - Maintaining continuity in state estimates
   - Special visualization for transition period

2. **Missing Data Strategy**: Uses NaN propagation through the Kalman filter, allowing the filter to continue with prediction-only updates when polls are unavailable.

3. **Multi-source Aggregation**: The `multi_poll_aggregator.m` weights polls by sample size and recency, handling multiple polls per week robustly.

4. **Numerical Stability**: All probability estimates are bounded [0,1] with explicit checks in `kalman_update.m` and confidence interval calculations.

## Key Files and Their Roles

### Data Processing Layer
- `data/aggregate_weekly.m`: Creates the 52-week dataset that drives the entire system
- `data/handle_transition.m`: Analyzes the Biden→Harris transition dynamics

### Kalman Filter Core
- `core/kalman_filter.m`: Main orchestrator that calls predict/update in sequence
- `core/adaptive_noise.m`: Estimates optimal Q and R from innovation sequences

### Processing Pipeline
- `pipeline/weekly_processor.m`: The main entry point for running the full 52-week analysis
- `pipeline/polls_to_probability.m`: Critical conversion from poll percentages to win probabilities

### Validation Framework
- `backtest/run_backtest.m`: Comprehensive validation against 2024 actual results
- `backtest/calculate_metrics.m`: Computes Brier score, log score, RMSE, MAE

### Visualization Suite
- `viz/generate_report.m`: Creates all plots and exports publication-ready report
- `viz/plot_diagnostics.m`: Filter health monitoring (innovation, gain, uncertainty)

## Important Implementation Details

### Parameter Configuration
Default parameters are set in `core/kalman_init.m`:
- Initial state: x(0) = 0.5 (50% win probability)
- Initial covariance: P(0) = 0.1
- Process noise: Q = 0.001 (normal), 0.005 (transition)
- Measurement noise: R = 0.05

### Data Format Requirements
Weekly polls CSV must contain:
- `week`: Week number (1-52)
- `dem_avg`: Democratic polling average
- `rep_avg`: Republican polling average
- `candidate`: "Biden" or "Harris"
- `num_polls`: Number of polls aggregated

### Testing Coverage
All core functions have corresponding unit tests. Tests use synthetic data generation (`create_test_data.m`) to ensure reproducibility and known ground truth validation.

## Current Development Status

**Completed Phases (1-5)**:
- Data acquisition and preprocessing
- Kalman filter implementation
- Weekly processing pipeline
- Backtesting framework
- Visualization suite

**In Progress (Phase 6)**:
- Grid search parameter optimization (`tuning/grid_search.m`)
- Cross-validation framework (`tuning/cross_validate.m`)
- Sensitivity analysis (`tuning/sensitivity_analysis.m`)

## Performance Considerations

- Matrix operations are vectorized for Octave efficiency
- Weekly aggregation pre-computes to avoid repeated file I/O
- Visualization functions cache computed results
- Backtest metrics are computed incrementally to handle large datasets

## Common Development Tasks

### Adding New Data Sources
1. Create parser in `data/` following `parse_polls.m` pattern
2. Update `aggregate_weekly.m` to merge new source
3. Add source comparison in `backtest/compare_sources.m`

### Modifying Filter Parameters
1. Edit defaults in `core/kalman_init.m`
2. Run sensitivity analysis: `cd tuning && sensitivity_analysis()`
3. Validate changes: `cd backtest && run_backtest()`

### Creating Custom Visualizations
1. Add function to `viz/` directory
2. Follow naming convention: `plot_<feature>.m`
3. Include in `generate_report.m` for batch generation

### Debugging Filter Behavior
```octave
cd viz
plot_diagnostics()  % Shows innovation, Kalman gain, uncertainty evolution
```

## Mathematical Foundation

The Kalman filter equations implemented:

**Prediction Step**:
- x̂(k|k-1) = F * x̂(k-1|k-1)
- P(k|k-1) = F * P(k-1|k-1) * F' + Q

**Update Step**:
- K(k) = P(k|k-1) * H' / (H * P(k|k-1) * H' + R)
- x̂(k|k) = x̂(k|k-1) + K(k) * (z(k) - H * x̂(k|k-1))
- P(k|k) = (I - K(k) * H) * P(k|k-1)

Where F=1, H=1 for this scalar implementation.