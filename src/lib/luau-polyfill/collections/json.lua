if _G.ROBLOX then
    local HttpService = game:GetService('HttpService') :: HttpService

    local function encode(value: unknown)
        return HttpService:JSONEncode(value)
    end

    return {
        encode = encode,
    }
else
    local net = (require :: any)('@lune/net')

    local function encode(value: unknown)
        return net.jsonEncode(value)
    end

    return {
        encode = encode,
    }
end
