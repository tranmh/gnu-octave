# Kalman Filter Election Prediction System
## 2024 US Presidential Election: Trump vs Biden/Harris

A Kalman filter-based system for predicting the 2024 US Presidential election outcome using polling data from multiple sources. This implementation uses GNU Octave for all computations and visualizations.

## Project Overview

**Goal**: Predict the winner of the 2024 US Presidential election using a Kalman filter that processes weekly polling data from November 5, 2023 to November 5, 2024 (52 weeks).

**Candidates**: 
- Republican: Donald Trump
- Democrat: Joe Biden (Nov 2023 - July 21, 2024) → Kamala Harris (July 21, 2024 - Nov 2024)

**Actual 2024 Results** (for validation):
- Winner: Donald Trump
- Popular Vote: Trump ~50.1%, Harris ~48.3%
- Electoral College: Trump 312, Harris 226

## Features

- **Multi-source polling integration**: FiveThirtyEight, RealClearPolitics, Kaggle
- **Weekly state estimation**: 52-week prediction timeline
- **Candidate transition handling**: Special treatment for Biden→Harris switch
- **Backtesting**: Validation against actual 2024 results
- **Native Octave visualization**: Comprehensive plotting and reporting
- **Uncertainty quantification**: Confidence intervals and Kalman gain tracking

## Implementation Status

- [x] **Phase 1**: Data Acquisition & Preprocessing ✓ COMPLETE
- [ ] **Phase 2**: Kalman Filter Core Implementation
- [ ] **Phase 3**: Weekly Update System
- [ ] **Phase 4**: Backtesting Framework
- [ ] **Phase 5**: Visualization
- [ ] **Phase 6**: Parameter Tuning & Validation

## Requirements

- **GNU Octave**: Version 10.3.0 or later
- **No additional packages required** - uses only base Octave functions
- **Internet connection**: For downloading polling data

## Quick Start

### Phase 1: Data Processing (COMPLETE)

1. **Download polling data**:
   ```octave
   cd data
   download_data()
   ```

2. **Parse the raw polling data**:
   ```octave
   poll_data = parse_polls();
   ```

3. **Aggregate into weekly averages**:
   ```octave
   weekly_data = aggregate_weekly();
   ```

4. **Analyze transition period**:
   ```octave
   handle_transition();
   ```

5. **Run tests**:
   ```octave
   cd ../tests
   test_data_processing();
   ```

### Expected Output Files

After completing Phase 1, you should have:
- `data/raw/fivethirtyeight_polls.csv` - Raw polling data
- `data/processed/parsed_polls.csv` - Cleaned Trump vs Biden/Harris polls
- `data/processed/weekly_polls.csv` - 52 weeks of aggregated polling data

## Project Structure

```
election-kalman-filter/
├── README.md                    # This file
├── ImplementationPlan.md        # Detailed phase-by-phase plan
├── main.m                       # Main execution script
│
├── data/                        # Data processing (Phase 1 ✓)
│   ├── raw/                     # Downloaded polling data
│   ├── processed/               # Cleaned and aggregated data
│   ├── download_data.m          # Download polling data
│   ├── parse_polls.m            # Parse and filter polls
│   ├── aggregate_weekly.m       # Weekly aggregation
│   └── handle_transition.m      # Transition analysis
│
├── core/                        # Kalman filter (Phase 2)
│   ├── kalman_init.m
│   ├── kalman_predict.m
│   ├── kalman_update.m
│   ├── kalman_filter.m
│   └── adaptive_noise.m
│
├── pipeline/                    # Processing pipeline (Phase 3)
│   ├── weekly_processor.m
│   ├── polls_to_probability.m
│   ├── multi_poll_aggregator.m
│   └── transition_handler.m
│
├── backtest/                    # Validation (Phase 4)
│   ├── run_backtest.m
│   ├── calculate_metrics.m
│   ├── confidence_intervals.m
│   └── compare_sources.m
│
├── viz/                         # Visualization (Phase 5)
│   ├── plot_prediction_timeline.m
│   ├── plot_confidence_bands.m
│   ├── plot_polls_vs_estimate.m
│   ├── plot_transition_period.m
│   ├── plot_final_comparison.m
│   ├── plot_diagnostics.m
│   └── generate_report.m
│
├── tuning/                      # Parameter optimization (Phase 6)
│   ├── grid_search.m
│   ├── cross_validate.m
│   ├── sensitivity_analysis.m
│   ├── compare_methods.m
│   └── final_params.m
│
├── tests/                       # Unit tests
│   ├── test_data_processing.m   # Phase 1 tests ✓
│   ├── test_kalman_core.m
│   ├── test_pipeline.m
│   └── run_all_tests.m
│
└── utils/                       # Utilities
    ├── date_utils.m
    ├── polling_utils.m
    └── validation_utils.m
```

## Kalman Filter Model

### State-Space Representation

**State Variable**: 
- `x(t)` = True Democratic nominee win probability

**Observation Variable**:
- `z(t)` = Polling-derived win probability

**Process Model**:
```
x(t+1) = x(t) + w(t)
where w(t) ~ N(0, Q)  [process noise]
```

**Measurement Model**:
```
z(t) = x(t) + v(t)
where v(t) ~ N(0, R)  [measurement noise]
```

### Initial Conditions

- `x(0)` = 0.5 (50% prior win probability)
- `P(0)` = 0.1 (initial uncertainty)
- `Q` = 0.001 (process noise, to be tuned)
- `R` = 0.05 (measurement noise, to be tuned)

### Transition Handling (Week 38: July 21, 2024)

- **Increased process noise**: `Q_transition = 5 * Q`
- **Reset uncertainty**: `P_reset = 0.15`
- **Duration**: Weeks 38-40 (3 weeks)

## Data Sources

**Primary**: [FiveThirtyEight](https://projects.fivethirtyeight.com/polls/)
- Comprehensive polling database
- Quality ratings for pollsters
- Adjusted and raw percentages
- Historical data back to 1998

**Secondary** (optional):
- Kaggle election datasets
- RealClearPolitics aggregations
- Wikipedia polling tables

## Phase 1: Data Processing Details

### Download Data (`download_data.m`)
- Fetches FiveThirtyEight CSV files via `urlwrite()`
- Stores in `data/raw/` directory
- Includes error handling for network issues

### Parse Polls (`parse_polls.m`)
- Filters for 2024 presidential race
- Extracts Trump vs Biden/Harris matchups only
- Validates polling percentages (0-100%)
- Groups by question ID to match candidates
- Outputs cleaned CSV with paired results

### Aggregate Weekly (`aggregate_weekly.m`)
- Divides 52-week period (Nov 5, 2023 - Nov 5, 2024)
- Calculates mean and std dev per week
- Handles missing weeks via linear interpolation
- Tracks candidate transition (Biden→Harris)
- Outputs weekly CSV for Kalman filter input

### Handle Transition (`handle_transition.m`)
- Analyzes Biden→Harris switch on July 21, 2024
- Compares polling before/after transition
- Provides recommendations for filter parameters
- Validates transition week identification

## Testing

Run all Phase 1 tests:
```octave
cd tests
test_data_processing()
```


Expected output:
```
========================================
  Phase 1 Testing: Data Processing
========================================

Test 1: Checking raw data files...
  ✓ Raw data file exists

Test 2: Checking parsed poll data...
  ✓ Parsed polls file exists
  ✓ Number of parsed polls: 1234
  ✓ Data is not empty

Test 3: Checking weekly aggregated data...
  ✓ Weekly polls file exists
  ✓ Number of weeks: 52
  ✓ Biden weeks: 37
  ✓ Harris weeks: 15
  ✓ Correct number of weeks (52)
  ✓ Both Biden and Harris weeks present

Test 4: Validating polling percentage ranges...
  Democratic range: 42.0% - 50.0%
  Republican range: 45.0% - 52.0%
  ✓ All percentages in valid range [0, 100]

Test 5: Validating date ranges...
  First week start: 2023-11-05
  Last week end: 2024-11-11
  ✓ Start date matches expected (Nov 2023)
  ✓ End date matches expected (Nov 2024)

========================================
  ✓ ALL TESTS PASSED
  Phase 1 data processing is complete!
========================================
```

## Troubleshooting

### Download Issues
If `urlwrite()` fails:
1. Check internet connection
2. Manually download from: https://projects.fivethirtyeight.com/polls/data/president_polls.csv
3. Save to `data/raw/fivethirtyeight_polls.csv`

### Parsing Errors
- Ensure CSV format matches FiveThirtyEight schema
- Check for corrupted download (re-download if needed)
- Verify date formats are YYYY-MM-DD

### Missing Weeks
- Some weeks may have no polls (normal)
- `aggregate_weekly.m` interpolates missing weeks
- Check `num_polls` column in output CSV

## Future Enhancements


- Extended Kalman Filter (EKF) for non-linear dynamics
- State-by-state modeling for Electoral College prediction
- Incorporation of prediction markets and economic indicators
- Pollster quality weighting based on historical accuracy
- Real-time updating system for live predictions

## References

1. Welch & Bishop (2006) - "An Introduction to the Kalman Filter"
2. Silver, N. (2012) - "The Signal and the Noise"
3. FiveThirtyEight Methodology: https://fivethirtyeight.com/methodology/
4. GNU Octave Documentation: https://octave.org/doc/

## License

This is an educational project for learning Kalman filtering and election forecasting.

## Contributors

Developed as part of the GNU Octave scientific computing project series.

---

**Last Updated**: October 19, 2025  
**Current Phase**: Phase 1 Complete ✓
