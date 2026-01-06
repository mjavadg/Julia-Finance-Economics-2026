using DataFrames, Dates, Random, Statistics, Plots, YFinance

eth_raw = get_prices("ETH-USD", range="3y", interval="1d")
ETH = DataFrame(Date = eth_raw["timestamp"], Close = eth_raw["close"])

spx_raw = get_prices("^GSPC", range="3y", interval="1d")
SPX = DataFrame(Date = spx_raw["timestamp"], Close = spx_raw["close"])


function reflect_path(prices, lower_barrier, upper_barrier)
    log_prices = log.(prices)

    idx = findfirst(x -> lower_barrier <= x <= upper_barrier, log_prices)
    idx === nothing && return nothing, nothing

    reflect = copy(log_prices)
    for i in idx+1:length(log_prices)
        reflect[i] = 2 * log_prices[idx] - log_prices[i]
    end

    return idx, exp.(reflect)
end

function compute_drawdown(prices)
    peak = prices[1]
    dd = similar(prices)

    for i in eachindex(prices)
        peak = max(peak, prices[i])
        dd[i] = (peak - prices[i]) / peak
    end

    return dd
end

function rolling_volatility(returns, window)
    return [std(returns[i-window+1:i]) for i in window:length(returns)]
end

function analyze_asset(df; lower, upper, window=14)
    prices = df.Close
    dates  = df.Date

    lower_b = log(lower)
    upper_b = log(upper)

    idx, reflected_prices = reflect_path(prices, lower_b, upper_b)
    idx === nothing && error("Barrier never hit")

    real_after = prices[idx:end]
    refl_after = reflected_prices[idx:end]
    dates_after = dates[idx:end]

    dd_real = compute_drawdown(real_after)
    dd_refl = compute_drawdown(refl_after)

    ret_real = diff(log.(real_after))
    ret_refl = diff(log.(refl_after))

    vol_real = rolling_volatility(ret_real, window)
    vol_refl = rolling_volatility(ret_refl, window)

    return (
        idx = idx,
        dates_after = dates_after,
        dd_real = dd_real,
        dd_refl = dd_refl,
        vol_real = vol_real,
        vol_refl = vol_refl
    )
end


eth_result = analyze_asset(ETH; lower=2000, upper=2200)
spx_result = analyze_asset(SPX; lower=4500, upper=4600)

plot(eth_result.dates_after, eth_result.dd_real, label="ETH Real DD")
plot!(eth_result.dates_after, eth_result.dd_refl, label="ETH Reflected DD", linestyle=:dash)

max_dd_real_eth = maximum(eth_result.dd_real)
max_dd_refl_eth = maximum(eth_result.dd_refl)

println("ETH Max DD (real): ", round(max_dd_real_eth*100, digits=2), "%")
println("ETH Max DD (reflected): ", round(max_dd_refl_eth*100, digits=2), "%")

idx_dd_real_eth = argmax(eth_result.dd_real)
idx_dd_refl_eth = argmax(eth_result.dd_refl)

date_dd_real_eth = eth_result.dates_after[idx_dd_real_eth]
date_dd_refl_eth = eth_result.dates_after[idx_dd_refl_eth]

println("ETH real max DD date: ", date_dd_real_eth)
println("ETH reflected max DD date: ", date_dd_refl_eth)

plot(spx_result.vol_real, label="S&P Real Vol")
plot!(spx_result.vol_refl, label="S&P Reflected Vol", linestyle=:dash)

max_dd_real_spx = maximum(spx_result.dd_real)
max_dd_refl_spx = maximum(spx_result.dd_refl)

println("SPX Max DD (real): ", round(max_dd_real_spx*100, digits=2), "%")
println("SPX Max DD (reflected): ", round(max_dd_refl_spx*100, digits=2), "%")

idx_dd_real_spx = argmax(spx_result.dd_real)
idx_dd_refl_spx = argmax(spx_result.dd_refl)

date_dd_real_spx = spx_result.dates_after[idx_dd_real_spx]
date_dd_refl_spx = spx_result.dates_after[idx_dd_refl_spx]

println("SPX real max DD date: ", date_dd_real_spx)
println("SPX reflected max DD date: ", date_dd_refl_spx)
