local ultimaAccion = nil
local currentGarage = nil
local fetchedVehicles = {}
local fueravehicles = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('modo:LeyRider', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

function MenuGarage(action)
    if not action then action = ultimaAccion; elseif not action and not ultimaAccion then action = "menu"; end
    ped = GetPlayerPed(-1);
    MenuTitle = "Garage"
    ClearMenu()
    ultimaAccion = action
    Citizen.Wait(150)
    DeleteActualVeh()
    if action == "menu" then
        Menu.addButton("Garage","ListeVehicule",nil)
        Menu.addButton("Fourrière","recuperar",nil)
        Menu.addButton("Fermer","CloseMenu",nil) 
    elseif action == "vehicle" then
        PutInVehicle()
    end
end

function EnvioVehLocal(veh)
    local slots = {}
    for c,v in pairs(veh) do
        table.insert(slots,{["garage"] = v.garage, ["vehiculo"] = json.decode(v.vehicle)})
    end
    fetchedVehicles = slots
end

function EnvioVehFuera(data)
    local slots = {}
    for c,v in pairs(data) do
        print(v.state)
        if v.state == 0 or v.state == 2 or v.state == false or v.garage == nil then
            table.insert(slots,{["vehiculo"] = json.decode(v.vehicle),["state"] = v.state})
        end
    end
    fueravehicles = slots
end

function recuperar()
    currentGarage = cachedData["currentGarage"]

    if not currentGarage then
        CloseMenu()
        return 
    end

   HandleCamera(currentGarage, true)
   ped = GetPlayerPed(-1);
   MenuTitle = "Fourrière :"
   ClearMenu()
   Menu.addButton("Retour","MenuGarage",nil)
    for c,v in pairs(fueravehicles) do
        local vehicle = v.vehiculo
        if v.state == 0 or v.state == false then
            Menu.addButton("SAVE | "..GetDisplayNameFromVehicleModel(vehicle.model), "pagorecupero", vehicle, "CEKILMIS", " État : " .. round(vehicle.engineHealth) /10 .. "%", " Essence : " .. round(vehicle.fuelLevel) .. "%","SpawnLocalVehicle")
        end
    end 
end

function pagorecupero(data)
    esx.TriggerServerCallback('erp_garage:checkMoney', function(hasEnoughMoney,deudas)
        if deudas then
            recuperar()
            ESX.ShowNotification('Vous devez plus de 2 000 $ au gouvernement, vous ne pouvez pas récupérer votre voiture tant que vous n\'avez pas payé vos amendes !')
        elseif hasEnoughMoney == true then
            SpawnVehicle({data,nil},true)
        else
            recuperar()
            ESX.ShowNotification('Il n\'y a pas d\'argent dessus')							
        end
    end)
end


function AbrirMenuGuardar()
    currentGarage = cachedData["currentGarage"]
    if not currentGarage then
        CloseMenu()
        return 
    end
   ped = GetPlayerPed(-1);
   MenuTitle = "Save :"
   ClearMenu()
   Menu.addButton("CLOSE","CloseMenu",nil)
   Menu.addButton("GARAGE: "..currentGarage.." | STORING THE CAR", "SaveInGarage", currentGarage, "", "", "","DeleteActualVeh")
end

function ListeVehicule()
    currentGarage = cachedData["currentGarage"]

    if not currentGarage then
        CloseMenu()
        return 
    end

   HandleCamera(currentGarage, true)
   ped = GetPlayerPed(-1);
   MenuTitle = "My vehicles :"
   ClearMenu()
   Menu.addButton("Retour","MenuGarage",nil)
    for c,v in pairs(fetchedVehicles) do
        if v then
            local vehicle = v.vehiculo
            Menu.addButton("" ..(vehicle.plate).." | "..GetDisplayNameFromVehicleModel(vehicle.model), "OptionVehicle", {vehicle,nil}, "Garage: "..currentGarage.."", " État : " .. round(vehicle.engineHealth) /10 .. "%", " Essence : " .. round(vehicle.fuelLevel) .. "%","SpawnLocalVehicle")
        end
    end
end

function round(n)
    if not n then return 0; end
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function OptionVehicle(data)
   MenuTitle = "Options :"
   ClearMenu()
   Menu.addButton("Sortir le vehicule", "SpawnVehicle", data)
   Menu.addButton("Retour", "ListeVehicule", nil)
end

function CloseMenu()
    HandleCamera(currentGarage, false)
	TriggerEvent("inmenu",false)
    Menu.hidden = true
end

function LocalPed()
	return GetPlayerPed(-1)
end
