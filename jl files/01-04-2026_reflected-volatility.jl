using CSV, DataFrames, Dates, Random, Statistics, Plots, StatsBase

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


return_of_real = diff(log.(real_price_after_barrier))
return_of_reflected = diff(log.(reflected_price_after_barrier))

w = 14
vol_real = [std(return_of_real[i-w+1:i]) for i in w:length(return_of_real)] # rolling volatility for reflected returns 
vol_reflected = [std(return_of_reflected[i-w+1:i]) for i in w:length(return_of_reflected)]

dates = BTC_price.Date[first_index + 1: end]

#plot(dates, real_price_after_barrier[2 : end], label="Real Price", color =:blue)
#plot!(dates, reflected_price_after_barrier[2 : end], label="Reflected Price", color =:red, linestyle=:dash)

plot(dates[w:end], vol_real, label="Real Volatility", color=:darkblue, linewidth=5)
plot!(dates[w:end], vol_reflected, label="Reflected Volatility", color=:yellow, linestyle=:dash)

println("mean of real vol: ", mean(vol_real))
println("mean of reflected vol: ",mean(vol_reflected))
println("variance of real vol: ", var(vol_real))
println("variance of reflected vol: ", var(vol_reflected))
