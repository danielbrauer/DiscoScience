local fakeRandom = {}

fakeRandom.fakeValue = 0

fakeRandom.random = function (arg1, arg2)
    return fakeRandom.fakeValue
end

return fakeRandom