# SPY Volatility Modeling Using ARIMA and GARCH in R

This project analyzes the volatility of the SPY ETF (tracking the S&P 500) using time series analysis. The goal is to remove autocorrelation in daily returns using ARIMA modeling, and then capture volatility clustering using a GARCH(1,1) model.

## Methods Used

- **Data Source:** Yahoo Finance (SPY prices from 2015 to present)
- **Models:** ARIMA, GARCH(1,1)
- **Tests:** Augmented Dickey-Fuller (ADF), KPSS for stationarity testing
- **Visualization:** ggplot2
- **Libraries:** quantmod, rugarch, forecast, tseries, ggplot2, dplyr

## Project Workflow

1. Download SPY historical price data and calculate daily log returns.
2. Explore the return distribution and volatility patterns.
3. Test for stationarity using ADF and KPSS.
4. Fit an ARIMA model to remove autocorrelation.
5. Model conditional volatility using GARCH(1,1).
6. Forecast volatility for the next 30 days.
7. Visualize all results.

## Viewing the Report Without R

The generated HTML report (`SPY-Volatility-Project.html`) can be downloaded and opened directly in any modern web browser. This allows anyone to explore the full analysis, code, and visualizations without needing to install R or run any code.


## How to Run the Project with R

1. Clone this repository or download the `SPY Volatility Project.Rmd` file.  
2. Open `SPY Volatility Project.Rmd` in RStudio.  
3. Click **Knit** to run the analysis and generate the HTML report with all graphs and results.  
4. The report will open automatically in RStudio’s viewer or your default web browser. You can also find the saved `.html` file in your working directory to open or share later.

Make sure the following R packages are installed before knitting:

```r
install.packages(c("quantmod", "rugarch", "forecast", "tseries", "ggplot2", "dplyr"))

