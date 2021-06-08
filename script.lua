local maxTemp = 2000
local minTemp = 1900
local updatePause = 1
local controlRodSteps = 1
local boundaries = 50
local textSize = 1
local textColour = 1
local backgroundColour = 32768
local reactor = peripheral.find("BiggerReactors_Reactor")
local monitor = peripheral.find('monitor')

--[[
function outputStuff()
    local s={}
    local n=0
    for k in pairs(reactor) do
        n=n+1 s[n]=k
    end
    table.sort(s)
    for k,v in ipairs(s) do
        f = reactor[v]
        if type(f) == "function" then
            print(v)
        end
    end
end
--]]

function startReactor()
    if not reactor.active() then
        reactor.setActive(true)
    end
end

function getInfo()
    local info = {}

    info["temp"] = reactor.casingTemperature()
    info["rodLevel"] = reactor.getControlRod(0).level()

    info["eng"] = reactor.battery().stored()
    info["maxEng"] = reactor.battery().capacity()

    info["fuel"] = reactor.fuelTank().fuel()
    info["fuelUsage"] = reactor.fuelTank().burnedLastTick()
    info["maxFuel"] = reactor.fuelTank().capacity()
    info["waste"] = reactor.fuelTank().waste()

    if reactor.coolantTank() ~= nil then
        info["coolantPresent"] = true
    else
        info["coolantPresent"] = false
    end

    return info
end

function round(value, places)
    local factor = 10
    local i

    for i=1, places do
        factor = factor * 10
    end

    return math.floor(value * factor)/factor
end

function newLine()
  local _,cY= monitor.getCursorPos()
  monitor.setCursorPos(1,cY+1)
end

function updateDisplay(info)
    if monitor ~= nil then
        monitor.clear()
        monitor.setCursorPos(1, 1)
        -- Temperature
        monitor.write("Temperature : ")
        monitor.write(round(info["temp"],2))
        monitor.write("/")
        monitor.write(round(maxTemp,2))
        newLine()
        newLine()

        -- Local Battery
        monitor.write("Energy Stored : ")
        monitor.write(round(info["eng"],2))
        monitor.write("/")
        monitor.write(round(info["maxEng"],2))
        newLine()
        newLine()


        -- Fuel
        monitor.write("Fuel : ")
        monitor.write(round(info["fuelUsage"],3))
        monitor.write(" : ")
        monitor.write(round(info["fuel"],2))
        monitor.write("/")
        monitor.write(round(info["maxFuel"],2))
        newLine()
        monitor.write("Waste : ")
        monitor.write(round(info["waste"],2))
        newLine()
        newLine()
    end
end

function maintainBelow()
    while true do
        local info = getInfo()
        local controlRodStep = math.abs((info["temp"] - maxTemp) / boundaries ) * controlRodSteps
    	if info["temp"] > maxTemp then
        	reactor.setAllControlRodLevels(info["rodLevel"] + controlRodStep)
        end
        if info["temp"] < minTemp then
            reactor.setAllControlRodLevels(info["rodLevel"] - controlRodStep)
        end
        updateDisplay(info)
        sleep(updatePause)
    end
end

if reactor == nil then
    print("No reactor found.")
else
    local temp = reactor.fuelTank().burnedLastTick()
    if temp == nil then
        print("Got nill for connected test.")
    else
        if monitor == nil then
            print("No monitor detected...")
        else
            monitor.setTextScale(textSize)
            monitor.setTextColour(textColour)
            monitor.setBackgroundColour(backgroundColour)
            print("Starting Program...")
            startReactor()
            maintainBelow()
        end
	end
end
