# Defining Functions
#1st way

function square(x)
    return x ^ 2
end

square(2)

#2nd way

square2(x) = x ^ 2

square2(8)

# Functions With Loops

function count_above_threshold(arr, t)
    count = 0
    for x in arr
        if x > t
            count += 1
        end
    end
    return count
end

count_above_threshold([1, 2, 3, 4, 5], 2)

# Functions That Work on Arrays

function log_returns(prices)
    return diff(log.(prices))
end

using CSV, DataFrames

btc_daily_candles = CSV.read("btc_candlestick_data.csv", DataFrame)

close_p = btc_daily_candles.Close 

log_returns(close_p)

# Functions With Conditions


function first_above(arr, t)
    for (i, x) in pairs(arr)
        if x > t
            return i
        end
    end
    return nothing
end

first_above([1, 2, 3, 5, 9], 3)

# Functions Returning Multiple Values

function stats(arr)
    return mean(arr), var(arr), std(arr)
end

stats(close_p)

    
