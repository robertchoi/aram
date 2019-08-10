mylib = require "mylib"
--must start with mylib = require "mylib". Be sure to put it in the first line. If the first line is left blank, an exception will be reported.


--Write date into the blockChain
WriteStrkeyValueToDb = function (Strkey,ValueTbl)
    local t = type(ValueTbl)
    assert(t == "table","the type of Value isn't table.")

    local writeTbl = {
        key = Strkey,
        length = #ValueTbl,
        value = {}
    }
    writeTbl.value = ValueTbl

    if not mylib.WriteData(writeTbl) then  error("WriteData error") end
end

--get external call context
GetContractTxParam = function (startIndex, length)
    assert(startIndex > 0, "GetContractTxParam start error(<=0).")
    assert(length > 0, "GetContractTxParam length error(<=0).")
    assert(startIndex+length-1 <= #contract, "GetContractTxParam length ".. length .." exceeds limit: " .. #contract)

    local newTbl = {}
    --local i = 1
    for i = 1,length do
        newTbl[i] = contract[startIndex+i-1]
    end
    return newTbl
end

---------------------------------------------------

--save to the chain create user input ability
SaveHelloToChain = function(contextTbl)
    WriteStrkeyValueToDb("name",contextTbl)
end

--table to String
Serialize = function(obj, hex)
    local lua = ""
    local t = type(obj)

    if t == "table" then
        for i=1, #obj do
            if hex == false then
                lua = lua .. string.format("%c",obj[i])
            elseif hex == true then
                lua = lua .. string.format("%02x",obj[i])
            else
                error("index type error.")
            end
        end
    elseif t == "nil" then
        return nil
    else
        error("can not Serialize a " .. t .. " type.")
    end

    return lua
end

Unpack = function (t,i)
    i = i or 1
    if t[i] then
        return t[i], Unpack(t,i+1)
    end
end


----Entry function of smart contract
Main = function()

    -- cant save a string directly to the blockchain it must be converted to hex
    local key_lenTbl = GetContractTxParam(1 ,4)  --name's length Tbl
    local key_len = mylib.ByteToInteger(Unpack(key_lenTbl))  --name's length Int
    local keyTbl = GetContractTxParam(4 +1,key_len)--name Tbl

    local value_lenTbl = GetContractTxParam(4 + key_len + 1 ,4)  --age's length Tbl
    local value_len = mylib.ByteToInteger(Unpack(value_lenTbl))  --age's length Int
    local valueTbl = GetContractTxParam(4+key_len+ 4 + 1,value_len)

    local keyStr = Serialize(keyTbl,false)

    WriteStrkeyValueToDb(keyStr, valueTbl)


end

Main()

