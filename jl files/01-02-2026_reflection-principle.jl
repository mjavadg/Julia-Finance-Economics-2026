using CSV, DataFrames, Dates, Random, Statistics, Plots

BTC_price = CSV.read("btc_candlestick_data", DataFrame)

log_prices = log.(BTC_price.Close)


lower_barrier = log(89000)
upper_barrier = log(91000)

# first match if exists

first_index = findfirst(x -> lower_barrier <= x <= upper_barrier, log_prices)

price_barrier_index = first_index

# reflecting the path after barrier

reflect = copy(log_prices)
if price_barrier_index !== nothing && price_barrier_index < length(log_prices)
    for i in price_barrier_index + 1: length(log_prices)
        reflect[i] = 2 * log_prices[price_barrier_index] - log_prices[i]
    end
end

reflect_prices = exp.(reflect)

plot(BTC_price.Date, BTC_price.Close, label="Original Price")
plot!(BTC_price.Date, reflect_prices, label="Reflected Path", linestyle=:dash)

