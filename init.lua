local tables = require 'tables'
tables.script_names = require 'script_names'

function tables.match(charmap, script)
    local first = 0
    local ridx = 1
    local available

    local hit = 0
    local miss = 0

    for i=1,#script,2 do
        first = first + script[i]
        local current = first
        local count = script[i+1]
::nextrange::
        assert(count >= 0)
        -- advance the charmap until we find a range that ends beyond or at the start of current script range
        while charmap[ridx][2] < current do
            ridx = ridx+1
            if ridx > #charmap then
                return hit, miss + count
            end
            assert(charmap[ridx-1][2] < charmap[ridx][1])
        end
        -- if it starts beyond current script
        local n = charmap[ridx][1] - current
        if n > 0 then
            if n > count then
                -- missing entire script range
                miss = miss + count
                goto gonext
            end
            -- so those characters are missing
            miss = miss + n
            -- and advance beyond em
            current = current + n
            count = count - n
        end
        available = charmap[ridx][2] - current + 1
        assert(available >= 0)
        -- it spans less than current count
        if available < count then
            -- consume that part
            count = count - available
            hit = hit + available
            current = current + available
            -- and go find next range
            goto nextrange
        end
        assert(count >= 0)

        -- it spans more, so all of count hits
        hit = hit + count
::gonext::
        first = first + script[i+1] - 1
    end
    return hit, miss
end


return tables
