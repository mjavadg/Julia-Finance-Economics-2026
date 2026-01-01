# Date: 01-01-2026
# Title: BTC Log Returns vs. Scaled Random Walk
# Data Source: BTC daily candlestick data (OHLCV) from 01-01-2023 to 01-01-2026, exported from Python using mplfinance
# At the moment, I am unsure whether it is possible to obtain the same date using Julia. However, I will find out soon!
# Description: Compares empirical BTC log returns to a scaled symmetric random walk (Wiener process approximation).

using CSV, DataFrames, Dates, Random, Statistics, Plots

btc_daily_candles = CSV.read("btc_candlestick_data.csv", DataFrame) 

btc_daily_candles.Date = Date.(string.(btc_daily_candles.Date), dateformat"yyyy-mm-dd")
dates = btc_daily_candles.Date[window:length(btc_daily_candles.Date)]

btc_daily_candles.logret = [missing; diff(log.(btc_daily_candles.Close))] # Computing log return on the Close
returns = skipmissing(btc_daily_candles.logret)

returns_array = collect(returns)

# simulate scaled random walk
obs = length(returns_array)
limits = rand([-1, 1] , obs)
approach = cumsum(limits)
calc = approach ./ sqrt(obs)

plot(1:obs, cumsum(collect(returns)), label = "BTC Log Returns")
plot!(1:obs, calc, label = "Scaled Random walk", xlabel = "Time", ylabel = "Cumulative Return", title = "BTC vs. Scaled Random Walk")















