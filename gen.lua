local script_names = require 'script_names'

local tab = {}

local compress = true
for l in io.open(arg[1]):lines() do
    if not l:match("^#") then
        local a,b = l:match("^ *([^ ]*) *; *([^ ]*)")
        if a then
            local a1,a2 = a:match("([0-9A-F]*)%.?%.?(.*)")
            if not a2 or a2 == "" then
                a2=a1
            end
            a1 = tonumber(a1,16)
            a2 = tonumber(a2,16)
            --print(a1,a2,b)
            if not tab[b] then
                tab[b] = {}
            end
            table.insert(tab[b], {a1,a2})
        end
    end
end

local function compress_table(v)
    local prev = 0
    local res = {}

    table.sort(v, function(a,b)
        return a[1] < b[1]
    end)

    if not compress then
        for _, p in ipairs(v) do
            table.insert(res, string.format("{%d,%d}", p[1], p[2]))
        end
        return res
    end

    local first, last
    for _, p in ipairs(v) do
        if not last then
            first = p[1]
            last = p[2]
            table.insert(res, first) -- new delta
        elseif last + 1 >= p[1] then
            if last < p[2] then
                last = p[2] -- just extend count
            end
        else
            table.insert(res, last - first + 1) -- finish count
            assert(p[1] > last)
            table.insert(res, p[1] - last + 1) -- new delta
            first = p[1]
            last = p[2]
        end
    end
    table.insert(res, last - first + 1)
    return res
end

for k,v in pairs(tab) do
	tab[k] = compress_table(v)
end

local seen = {}
io.stdout:write("return {\n")
io.stdout:write("   scripts = {\n")
for idx, v in ipairs(script_names) do
    if tab[v] and #tab[v] > 0 then
        seen[v] = true
        if not compress then
	        io.stdout:write("       -- "..(v:gsub("_", " ")).."\n")
        end
        io.stdout:write("       {"..table.concat(tab[v], ",").."},\n")
    else
        io.stdout:write("       {},\n")
    end
end
for k,_ in pairs(tab) do
    assert(seen[k])
end
io.stdout:write("   },\n")
io.stdout:write("   langs = {\n")

local orthdir = arg[2]

local function translate(fname)
    return string.gsub(fname, "(.*/)(.*)%.orth", "%2"):gsub("_","-")
end

function parse_orth(fname, ret)
    for l in io.open(fname):lines() do
        if not l:match("^#") then
            local inc = l:match("^include (.*)")
            if inc then
                parse_orth(orthdir .. "/" .. inc, ret)
            else
                l = l:gsub("^0[xX]", "")
                local a,b = l:match("^([0-9a-fA-F]+)%-?([0-9a-fA-F]*)")
                if a then
                    if not b or b == "" then
                        b = a
                    end
                    assert(b>=a)
                    a = tonumber(a, 16)
                    b = tonumber(b, 16)
                    table.insert(ret, {a,b})
                end
            end
        end
    end
    return ret
end

local langs = {}
for i=3, #arg do
    local op = arg[i]
    langs[translate(op)] = compress_table(parse_orth(op, {}))
end

for k, v in pairs(langs) do
    io.stdout:write("       ['"..k.."'] = {"..table.concat(v, ",").."},\n")
end

io.stdout:write("   },\n")
io.stdout:write("}\n")


