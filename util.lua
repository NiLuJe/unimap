-- Pilfered from https://github.com/koreader/koreader-base/blob/master/ffi/util.lua

local util = {}

-- pairs(), but with *keys* sorted alphabetically.
-- c.f., http://lua-users.org/wiki/SortedIteration
-- See also http://lua-users.org/wiki/SortedIterationSimple
local function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic order.
    -- We use a temporary ordered key table that is stored in the table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1, #t.__orderedIndex do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
end

function util.orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate in order
    return orderedNext, t, nil
end

return util
