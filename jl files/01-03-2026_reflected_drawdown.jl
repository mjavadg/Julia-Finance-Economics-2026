using CSV, DataFrames, Dates, Random, Statistics, Plots

BTC_price = CSV.read("btc_candlestick_data.csv", DataFrame)

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

real_price_after_barrier = BTC_price.Close[first_index:end]
reflected_price_after_barrier = reflect_prices[first_index:end]

#plot(BTC_price.Date[first_index:end], real_price_after_barrier, label="Original Price")
#plot!(BTC_price.Date[first_index:end], reflected_price_after_barrier, label="Reflected Path", linestyle=:dash)

drawdown = similar(real_price_after_barrier)
real_price_peak = real_price_after_barrier[1]

for i in eachindex(real_price_after_barrier)
    real_price_peak = max(real_price_peak, real_price_after_barrier[i])
    drawdown[i] = (real_price_peak - real_price_after_barrier[i]) / real_price_peak
end

Reflected_drawdown = similar(reflected_price_after_barrier)
reflected_price_peak = real_price_after_barrier[1]

for i in eachindex(reflected_price_after_barrier)
    reflected_price_peak = max(reflected_price_peak, reflected_price_after_barrier[i])
    Reflected_drawdown[i] = (reflected_price_peak - reflected_price_after_barrier[i]) / reflected_price_peak
end

plot(BTC_price.Date[first_index:end], drawdown, label = "Real Drawdown")
plot!(BTC_price.Date[first_index:end], Reflected_drawdown, label = "Reflected Drawdown", linestyle=:dash)

max_dd_real = maximum(drawdown)
max_dd_reflect = maximum(Reflected_drawdown)

println("Max drawdown (real): ", round(max_dd_real*100, digits=2), "%")
println("Max drawdown (reflected): ", round(max_dd_reflect*100, digits=2), "%")

idx_dd_real = argmax(drawdown)
idx_dd_reflect = argmax(Reflected_drawdown)

date_dd_real = BTC_price.Date[first_index:end][idx_dd_real]
date_dd_reflect = BTC_price.Date[first_index:end][idx_dd_reflect]

println("Real max drawdown date: ", date_dd_real)
println("Reflected max drawdown date: ", date_dd_reflect)

