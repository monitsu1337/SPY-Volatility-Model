# Load required libraries
library(quantmod)
library(ggplot2)
library(dplyr)
library(stats)
library(tseries)
library(forecast)
library(rugarch)

# -------------------------------------------------
# Data Collection and Preparation
# -------------------------------------------------

# Retrieve historical SPY daily closing prices from Yahoo Finance
spy_data <- getSymbols("SPY", from = "2015-01-01", to = Sys.Date(), src = "yahoo", auto.assign = FALSE)

# Extract closing prices and convert the time series to a data frame
spy_close <- Cl(spy_data)
spy_df <- data.frame(
  Date = index(spy_close),
  Price = as.numeric(spy_close)
)

# Visualize the SPY daily closing prices
ggplot(spy_df, aes(x = Date, y = Price)) +
  geom_line(color = "blue", linewidth = 1) +
  labs(title = "SPY Daily Closing Price", x = "Date", y = "Price") +
  theme_minimal()

print("Download and plot successful!")

# -------------------------------------------------
# Log Returns Calculation and Visualization
# -------------------------------------------------

# Calculate daily log returns of SPY
returns_xts <- dailyReturn(spy_data, type = "log")
returns_df <- data.frame(
  Date = index(returns_xts),
  Returns = as.numeric(returns_xts)
)

# Display the first observations of the log returns
print(head(returns_df))

# Visualize the daily log returns
ggplot(returns_df, aes(x = Date, y = Returns)) +
  geom_line(color = "darkgreen", linewidth = 1) +
  labs(title = "SPY Daily Log Returns", x = "Date", y = "Log Return") +
  theme_minimal()

# -------------------------------------------------
# Exploratory Data Analysis
# -------------------------------------------------

# Visualize the distribution of returns with a histogram and density curve
ggplot(returns_df, aes(x = Returns)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50, fill = "lightblue", color = "black") +
  geom_density(color = "red", linewidth = 1) +
  labs(title = "Histogram of SPY Daily Log Returns", x = "Returns", y = "Density") +
  theme_minimal()

# ACF plots (base R)
acf(returns_xts, main = "ACF of SPY Daily Log Returns")
acf(returns_xts^2, main = "ACF of Squared SPY Daily Log Returns")

# Visualize squared returns as a proxy for volatility
returns_df <- returns_df %>% mutate(Squared_Returns = Returns^2)

ggplot(returns_df, aes(x = Date, y = Squared_Returns)) +
  geom_col(fill = "purple") +
  labs(title = "Squared SPY Daily Log Returns (Volatility Proxy)", x = "Date", y = "Squared Return") +
  theme_minimal()

# -------------------------------------------------
# Stationarity Testing
# -------------------------------------------------

# Perform Augmented Dickey-Fuller test
adf_result <- adf.test(returns_df$Returns)
print(adf_result)

# Perform KPSS test
kpss_result <- kpss.test(returns_df$Returns)
print(kpss_result)

# -------------------------------------------------
# ARIMA Model Fitting
# -------------------------------------------------

# Fit an ARIMA model to the log returns
arima_fit <- auto.arima(returns_df$Returns)
summary(arima_fit)

# Extract residuals from the ARIMA model
arima_residuals <- residuals(arima_fit)
residuals_df <- data.frame(Date = returns_df$Date, Residuals = as.numeric(arima_residuals))

# Visualize ARIMA residuals
ggplot(residuals_df, aes(x = Date, y = Residuals)) +
  geom_line(color = "darkred", linewidth = 1) +
  labs(title = "ARIMA Model Residuals", x = "Date", y = "Residuals") +
  theme_minimal()

# -------------------------------------------------
# GARCH Model Estimation
# -------------------------------------------------

# Define the GARCH(1,1) model specification
spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "norm"
)

# Fit the GARCH(1,1) model to the ARIMA residuals
garch_fit <- ugarchfit(spec = spec, data = arima_residuals)

# Output the GARCH model summary
show(garch_fit)

# Extract the fitted conditional volatility estimates
sigma_fitted <- sigma(garch_fit)

# Prepare a data frame for fitted volatility
fitted_vol_df <- data.frame(
  Date = returns_df$Date,
  Volatility = as.numeric(sigma_fitted)
)

# Visualize the fitted conditional volatility
ggplot(fitted_vol_df, aes(x = Date, y = Volatility)) +
  geom_line(color = "orange", linewidth = 1) +
  labs(title = "Fitted Volatility from GARCH(1,1) Model", x = "Date", y = "Volatility") +
  theme_minimal()

# -------------------------------------------------
# Volatility Forecasting
# -------------------------------------------------

# Forecast volatility for the next 30 trading days
garch_forecast <- ugarchforecast(garch_fit, n.ahead = 30)
sigma_forecast <- sigma(garch_forecast)

# Prepare a data frame for the forecasted volatility
forecast_df <- data.frame(
  Day = 1:length(sigma_forecast),
  Volatility = as.numeric(sigma_forecast)
)

# Visualize the forecasted volatility
ggplot(forecast_df, aes(x = Day, y = Volatility)) +
  geom_line(color = "steelblue", linewidth = 1) +
  labs(title = "Forecasted Volatility (Next 30 Days)", x = "Days Ahead", y = "Volatility") +
  theme_minimal()
