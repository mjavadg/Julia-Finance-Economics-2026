# Date: 01-01-2026
# Title: Emprical vs. Theoretical Volatility Scaling
# Data Source: BTC daily candlestick data (OHLCV) from 01-01-2023 to 01-01-2026, exported from Python using mplfinance. 
# At the moment, I am unsure whether it is possible to obtain the same date using Julia. However, I will find out soon!
# Description: Computes 30-day rolling emrpical volatility of BTC log returns and compares it to the theoretical brownian motion scaling law 

using CSV, DataFrames, Dates, Random, Statistics, Plots

btc_daily_candles = CSV.read("btc_candlestick_data.csv", DataFrame) 

btc_daily_candles.Date = Date.(string.(btc_daily_candles.Date), dateformat"yyyy-mm-dd")

btc_daily_candles.logret = [missing; diff(log.(btc_daily_candles.Close))] # Computing log return on the Close
returns = skipmissing(btc_daily_candles.logret)

returns_array = collect(returns)

window = 30
dates = btc_daily_candles.Date[window:length(btc_daily_candles.Date)]

emprical_voltility = [std(skipmissing(btc_daily_candles.logret[i - window + 1:i])) for i in window:length(btc_daily_candles.logret)]

sigma = std(returns_array)

theoretical_voltility = [sigma * sqrt(t) for t in 1:length(emprical_voltility)]

plot(dates, emprical_voltility, label = "Emprical Voltility (30d)")
plot!(dates, theoretical_voltility, label = "Theoretical Brownian Scaling", xlabel = "Date" , ylabel = "Volatility", title = "BTC Volatility vs. Brownian Scaling")
