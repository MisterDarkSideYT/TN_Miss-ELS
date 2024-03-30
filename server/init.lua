elsxmlData = {}
local systemOS = nil

local function parseObjSet(data, fileName)
    local xml = SLAXML:dom(data)

    if xml and xml.root and xml.root.name == 'vcfroot' then ParseVCF(xml, fileName) end
end

local function determineOS()
    local system = nil

    local unix = os.getenv('HOME')
    local windows = os.getenv('HOMEPATH')

    if unix then system = 'unix' end
    if windows then system = 'windows' end

    -- this guy probably has some custom ENV var set...
    if unix and windows then error('Couldn\'t identify the OS unambiguously.') end

    return system
end

local function scanDir(folder)
    local pathSeparator = '/'
    local command = 'ls -A'

    if systemOS == 'windows' then
        pathSeparator = '\\'
        command = 'dir /R /B'
    end

    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local directory = resourcePath .. pathSeparator .. folder
    local i, t, popen = 0, {}, io.popen
    local pfile = popen(command .. ' "' .. directory .. '"')

    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end

    if #t == 0 then
        error('Couldn\'t find any VCF files. Are they in the correct directory?')
    end

    pfile:close()
    return t
end

local function loadFile(file)
    return LoadResourceFile(GetCurrentResourceName(), file)
end

AddEventHandler('onResourceStart', function(name)
    if not Config then
        error('You probably forgot to copy the example configuration file. Please see the installation instructions for further details.')
        StopResource(GetCurrentResourceName())
        CancelEvent()
        return
    end

    if name:lower() ~= GetCurrentResourceName():lower() then
        CancelEvent()
        return
    end

    local folder = 'xmlFiles'

    -- determine the server OS
    systemOS = determineOS()

    if not systemOS then
        error('Couldn\'t determine your OS! Are your running on steroids??')
    end

    for _, file in pairs(scanDir(folder)) do
        local data = loadFile(folder .. '/' .. file)

        if data then
            if pcall(function() parseObjSet(data, file) end) then
                -- no errors
                print('Parsed VCF for: ' .. file)
            else
                -- VCF is faulty, notify the user and continue
                print('VCF file ' .. file .. ' could not be parsed: is your XML valid?')
            end
        else
            print('VCF file ' .. file .. ' not found: does the file exist?')
        end
    end

    -- send the ELS data to all clients
    TriggerClientEvent('MISS-ELS:sendELSInformation', -1, elsxmlData)
end)

RegisterServerEvent('MISS-ELS:requestELSInformation')
AddEventHandler('MISS-ELS:requestELSInformation', function()
    TriggerClientEvent('MISS-ELS:sendELSInformation', source, elsxmlData)
end)

RegisterNetEvent('baseevents:enteredVehicle')
AddEventHandler('baseevents:enteredVehicle', function(veh, seat, name)
    TriggerClientEvent('MISS-ELS:initVehicle', source)
end)
