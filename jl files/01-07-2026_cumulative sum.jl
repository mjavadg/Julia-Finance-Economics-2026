# a function that returns the cumulative sum
function my_cumsum(arr)
    new_array = []
    total = 0
    for i in arr 
        total = total + i
        append!(new_array, total)
    end
    return new_array
end

my_cumsum([1, 2, 3, 4, 5])


            