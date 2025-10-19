# Kalman Filter Election Prediction System
## 2024 US Presidential Election: Trump vs Biden/Harris

---

## Project Overview

**Objective**: Use a Kalman filter to predict the winner of the 2024 US Presidential election starting one year before Election Day (Nov 5, 2024), with weekly updates.

**Time Period**: November 5, 2023 → November 5, 2024 (52 weeks)

**Candidates**: 
- Donald Trump (Republican)
- Joe Biden (Democrat) → Kamala Harris (from July 21, 2024)

**Approach**: Simple Kalman filter tracking Democratic nominee win probability from multiple polling sources

**Key Features**:
- Multiple polling source integration (FiveThirtyEight, RealClearPolitics, Kaggle)
- Weekly state estimation updates
- Candidate transition handling (Biden → Harris)
- Backtesting against actual 2024 results
- Native GNU Octave visualization

---

## Data Sources

### Primary Source: FiveThirtyEight
- **URL**: https://projects.fivethirtyeight.com/polls/data/president_polls.csv
- **Historical**: https://projects.fivethirtyeight.com/polls-page/data/president_polls_historical.csv
- **Features**: 
  - Raw and adjusted polling percentages
  - Pollster quality ratings
  - Sample sizes
  - Survey dates
  - Methodology transparency

### Secondary Sources:
1. **Kaggle**: https://www.kaggle.com/datasets/jpmiller/elections
2. **RealClearPolitics**: Via MacroMicro aggregator
3. **Wikipedia**: Compiled polling tables (manual extraction if needed)

---

## Kalman Filter Model Design

### State-Space Formulation

**State Variable**: 
- `x(t)` = True Democratic nominee win probability at time `t`

**Observation Variable**:
- `z(t)` = Polling-derived win probability at time `t`

**State Equation** (Process Model):
```
x(t+1) = x(t) + w(t)
where w(t) ~ N(0, Q)  [process noise]
```

**Observation Equation** (Measurement Model):
```
z(t) = x(t) + v(t)
where v(t) ~ N(0, R)  [measurement noise]
```

**Initial Conditions**:
- `x(0)` = 0.5 (50% prior win probability)
- `P(0)` = 0.1 (initial uncertainty)

**Noise Parameters** (to be tuned):
- `Q` = Process noise covariance (captures campaign dynamics)
- `R` = Measurement noise covariance (captures polling uncertainty)

### Candidate Transition Handling

On **July 21, 2024** (Week ~38):
- Increase process noise `Q` temporarily (2-3 weeks)
- Reset uncertainty `P` to higher value
- Continue tracking "Democratic nominee" probability
- Harris polls treated as continuation of Democratic nominee tracking

---

## Implementation Phases

### Phase 1: Data Acquisition & Preprocessing
**Goal**: Download, clean, and organize polling data from multiple sources

**Tasks**:
1. Download FiveThirtyEight CSV files
2. Parse and filter 2024 presidential polls (Trump vs Biden/Harris)
3. Handle missing data and outliers
4. Standardize polling percentages across sources
5. Create weekly aggregated observations

**Files to Create**:
- `data/download_data.m` - Download scripts for each source
- `data/parse_polls.m` - Parse and clean raw polling data
- `data/aggregate_weekly.m` - Create weekly polling averages
- `data/handle_transition.m` - Manage Biden→Harris transition

**Outputs**:
- `data/raw/fivethirtyeight_polls.csv`
- `data/processed/weekly_polls.csv`
- `data/processed/polling_metadata.csv`

**Testing**:
- Verify data completeness for 52-week period
- Check for Biden→Harris transition on July 21, 2024
- Validate polling percentage ranges [0, 100]

### Phase 2: Kalman Filter Core Implementation
**Goal**: Implement the Kalman filter algorithm in Octave

**Tasks**:
1. Initialize state and covariance matrices
2. Implement prediction step (time update)
3. Implement correction step (measurement update)
4. Handle missing observations (weeks without polls)
5. Implement adaptive noise estimation

**Files to Create**:
- `core/kalman_init.m` - Initialize filter parameters
- `core/kalman_predict.m` - Prediction step
- `core/kalman_update.m` - Correction step
- `core/kalman_filter.m` - Main filter loop
- `core/adaptive_noise.m` - Adaptive Q/R estimation

**Key Algorithms**:
```octave
% Prediction Step
x_pred = x_est;
P_pred = P_est + Q;

% Update Step (when measurement available)
K = P_pred / (P_pred + R);           % Kalman gain
x_est = x_pred + K * (z - x_pred);   % State update
P_est = (1 - K) * P_pred;            % Covariance update
```

**Testing**:
- Unit tests for prediction/update steps
- Synthetic data validation
- Noise parameter sensitivity analysis

### Phase 3: Weekly Update System
**Goal**: Process 52 weeks of polling data through the Kalman filter

**Tasks**:
1. Iterate through weekly polling observations
2. Convert polling percentages to win probabilities
3. Handle multiple polls per week (averaging/weighting)
4. Track state estimates and uncertainties over time
5. Implement transition period special handling (July 2024)

**Files to Create**:
- `pipeline/weekly_processor.m` - Main weekly update pipeline
- `pipeline/polls_to_probability.m` - Convert polls to win probability
- `pipeline/multi_poll_aggregator.m` - Combine multiple polls
- `pipeline/transition_handler.m` - Special logic for candidate switch

**Polling → Win Probability Conversion**:
```octave
% Simple logistic transformation
dem_pct = polling_average_democrat / 100;
rep_pct = polling_average_republican / 100;
margin = dem_pct - rep_pct;

% Convert margin to win probability (logistic curve)
win_prob = 1 / (1 + exp(-k * margin));
% where k is a scaling parameter (typically 10-20)
```

**Testing**:
- Week-by-week output validation
- Transition period behavior check
- Probability bounds verification [0, 1]

### Phase 4: Backtesting Framework
**Goal**: Validate predictions against actual 2024 election results

**Tasks**:
1. Implement rolling window backtest
2. Calculate prediction accuracy metrics
3. Compute confidence intervals
4. Compare final prediction vs actual outcome
5. Generate performance statistics

**Files to Create**:
- `backtest/run_backtest.m` - Main backtesting script
- `backtest/calculate_metrics.m` - Accuracy, RMSE, Brier score
- `backtest/confidence_intervals.m` - Uncertainty quantification
- `backtest/compare_sources.m` - Compare different polling sources

**Actual 2024 Results** (for validation):
- Election Date: November 5, 2024
- Winner: Donald Trump
- Popular Vote: Trump ~50.1%, Harris ~48.3%
- Electoral College: Trump 312, Harris 226

**Metrics to Calculate**:
- Final prediction error
- Brier score (probabilistic accuracy)
- Calibration plots
- Weekly prediction evolution
- Uncertainty band coverage

**Testing**:
- Cross-validation on historical elections (2016, 2020)
- Sensitivity to noise parameters Q and R
- Robustness to missing data

### Phase 5: Visualization
**Goal**: Create informative plots using native Octave graphics

**Tasks**:
1. Time series plot: Win probability over 52 weeks
2. Uncertainty bands (confidence intervals)
3. Polling observations vs Kalman estimates
4. Candidate transition visualization
5. Comparison: Prediction vs actual result
6. Kalman gain evolution plot
7. Innovation (residual) analysis

**Files to Create**:
- `viz/plot_prediction_timeline.m` - Main time series plot
- `viz/plot_confidence_bands.m` - Uncertainty visualization
- `viz/plot_polls_vs_estimate.m` - Observations vs filter
- `viz/plot_transition_period.m` - Focus on July 2024
- `viz/plot_final_comparison.m` - Prediction vs actual
- `viz/plot_diagnostics.m` - Filter diagnostics
- `viz/generate_report.m` - Combined report figure

**Plot Specifications**:
```octave
% Main prediction plot
figure('Position', [100, 100, 1200, 600]);
plot(weeks, win_probability, 'b-', 'LineWidth', 2);
hold on;
plot(weeks, upper_bound, 'r--', 'LineWidth', 1);
plot(weeks, lower_bound, 'r--', 'LineWidth', 1);
xlabel('Weeks Before Election');
ylabel('Democratic Nominee Win Probability');
title('Kalman Filter Election Prediction: 2024');
legend('Estimate', '95% Confidence');
grid on;
```

**Testing**:
- Visual inspection of all plots
- Export to PNG/PDF for documentation
- Verify all axis labels and legends

### Phase 6: Parameter Tuning & Validation
**Goal**: Optimize Kalman filter parameters for best performance

**Tasks**:
1. Grid search over Q and R values
2. Cross-validation on historical data
3. Sensitivity analysis
4. Comparative analysis with other methods
5. Final parameter selection and justification

**Files to Create**:
- `tuning/grid_search.m` - Parameter optimization
- `tuning/cross_validate.m` - Historical validation
- `tuning/sensitivity_analysis.m` - Robustness checks
- `tuning/compare_methods.m` - Benchmark comparisons
- `tuning/final_params.m` - Selected parameters

**Parameter Ranges to Explore**:
- `Q`: [0.0001, 0.001, 0.01, 0.1]
- `R`: [0.01, 0.05, 0.1, 0.2]
- Initial uncertainty `P(0)`: [0.05, 0.1, 0.2]

**Testing**:
- Optimal parameters minimize prediction error
- Stability across different initialization
- Reasonable behavior on historical data

---

## Directory Structure

```
election-kalman-filter/
│
├── ImplementationPlan.md          # This file
├── README.md                       # Project documentation
│
├── data/                           # Data acquisition and processing
│   ├── raw/                        # Raw downloaded data
│   │   ├── fivethirtyeight_polls.csv
│   │   ├── kaggle_polls.csv
│   │   └── rcp_polls.csv
│   ├── processed/                  # Cleaned and aggregated data
│   │   ├── weekly_polls.csv
│   │   └── polling_metadata.csv
│   ├── download_data.m
│   ├── parse_polls.m
│   ├── aggregate_weekly.m
│   └── handle_transition.m
│
├── core/                           # Kalman filter implementation
│   ├── kalman_init.m
│   ├── kalman_predict.m
│   ├── kalman_update.m
│   ├── kalman_filter.m
│   └── adaptive_noise.m
│
├── pipeline/                       # Weekly processing pipeline
│   ├── weekly_processor.m
│   ├── polls_to_probability.m
│   ├── multi_poll_aggregator.m
│   └── transition_handler.m
│
├── backtest/                       # Backtesting and validation
│   ├── run_backtest.m
│   ├── calculate_metrics.m
│   ├── confidence_intervals.m
│   └── compare_sources.m
│
├── viz/                            # Visualization
│   ├── plot_prediction_timeline.m
│   ├── plot_confidence_bands.m
│   ├── plot_polls_vs_estimate.m
│   ├── plot_transition_period.m
│   ├── plot_final_comparison.m
│   ├── plot_diagnostics.m
│   └── generate_report.m
│
├── tuning/                         # Parameter optimization
│   ├── grid_search.m
│   ├── cross_validate.m
│   ├── sensitivity_analysis.m
│   ├── compare_methods.m
│   └── final_params.m
│
├── tests/                          # Unit tests
│   ├── test_kalman_core.m
│   ├── test_data_processing.m
│   ├── test_pipeline.m
│   └── run_all_tests.m
│
├── utils/                          # Utility functions
│   ├── date_utils.m
│   ├── polling_utils.m
│   └── validation_utils.m
│
└── main.m                          # Main execution script

```

---

## Technical Specifications

### GNU Octave Requirements
- **Version**: 10.3.0 (installed)
- **Toolboxes**: Base Octave (no additional packages required)
- **Key Functions**: 
  - Matrix operations (vectorized)
  - File I/O (csvread, csvwrite)
  - Plotting (plot, figure, subplot)
  - Statistics (mean, std, cov)

### Data Format Specifications

**Weekly Polling CSV** (`data/processed/weekly_polls.csv`):
```
week_number, date, dem_avg, rep_avg, dem_std, rep_std, num_polls, candidate
1, 2023-11-05, 45.2, 46.8, 2.1, 1.9, 5, Biden
2, 2023-11-12, 44.9, 47.1, 2.3, 2.0, 4, Biden
...
38, 2024-07-21, 46.5, 47.5, 2.0, 1.8, 6, Biden
39, 2024-07-28, 48.1, 46.9, 2.2, 2.1, 7, Harris
...
52, 2024-11-05, 48.3, 50.1, 1.5, 1.4, 12, Harris
```

**Kalman Filter Output** (`results/kalman_estimates.csv`):
```
week_number, date, win_prob_est, win_prob_std, kalman_gain, innovation
1, 2023-11-05, 0.48, 0.12, 0.45, -0.02
2, 2023-11-12, 0.47, 0.10, 0.42, -0.01
...
```

### Algorithm Parameters

**Tunable Parameters**:
- `Q` = Process noise covariance (default: 0.001)
- `R` = Measurement noise covariance (default: 0.05)
- `P(0)` = Initial uncertainty (default: 0.1)
- `k` = Polling margin scaling (default: 15)

**Transition Period Adjustments** (Week 38-40):
- `Q_transition` = 5 * Q (increased uncertainty)
- `P_reset` = 0.15 (reset uncertainty)

---

## Development Workflow

### Phase Completion Criteria

Each phase is marked as **// DONE** in this file when:
1. All files listed are implemented
2. All tests pass
3. Documentation is complete
4. Code review completed (self-review)
5. Integration with previous phases verified

### Testing Strategy

**Unit Tests**: Test individual functions in isolation
- Input validation
- Boundary conditions
- Expected outputs

**Integration Tests**: Test phase combinations
- Data flow between phases
- End-to-end pipeline
- Error handling

**Validation Tests**: Compare with known results
- Historical election data
- Synthetic test cases
- Actual 2024 results

---

## Success Metrics

### Technical Metrics
- [ ] All 52 weeks of data processed successfully
- [ ] Kalman filter converges (no divergence)
- [ ] Final prediction within 10% of actual result
- [ ] Confidence intervals properly calibrated
- [ ] All visualizations render correctly

### Scientific Metrics
- [ ] Brier score < 0.15 (good probabilistic accuracy)
- [ ] Prediction captures major trends (Biden→Harris transition)
- [ ] Reasonable uncertainty quantification
- [ ] Outperforms naive baselines (moving average, latest poll)

### Deliverables
- [ ] Complete, documented, working Octave code
- [ ] Comprehensive visualization report
- [ ] Backtesting analysis report
- [ ] Parameter tuning justification
- [ ] README with usage instructions

---

## Phase Status

- [x] **Phase 1**: Data Acquisition & Preprocessing // DONE
- [x] **Phase 2**: Kalman Filter Core Implementation // DONE
- [x] **Phase 3**: Weekly Update System // DONE
- [ ] **Phase 4**: Backtesting Framework
- [ ] **Phase 5**: Visualization
- [ ] **Phase 6**: Parameter Tuning & Validation

---

## Notes and Considerations

### Assumptions
1. Polling data is reasonably accurate and unbiased
2. Kalman filter's linear assumptions approximately hold
3. Process noise represents campaign dynamics adequately
4. Candidate switch (Biden→Harris) can be modeled as increased uncertainty

### Limitations
1. **Simple state model**: Single win probability state (no state-level modeling)
2. **No external factors**: Economic indicators, debates, events not included
3. **Polling bias**: Systematic polling errors not fully corrected
4. **Linear assumption**: Real election dynamics may be non-linear

### Future Enhancements (Out of Scope)
- Extended Kalman Filter (EKF) for non-linear dynamics
- Multi-state model (state-by-state electoral college)
- Incorporation of prediction markets, economic data
- Pollster quality weighting
- Real-time updating system

---

## References

1. **Kalman Filtering**: Welch & Bishop (2006) - "An Introduction to the Kalman Filter"
2. **Election Forecasting**: Silver, N. (2012) - "The Signal and the Noise"
3. **FiveThirtyEight Methodology**: https://fivethirtyeight.com/methodology/
4. **GNU Octave Documentation**: https://octave.org/doc/

---

**Last Updated**: October 18, 2025
**Created By**: Election Kalman Filter Project Team
**Target Completion**: TBD