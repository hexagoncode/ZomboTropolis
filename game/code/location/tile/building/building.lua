local class = require('code.libs.middleclass')
local Tile = require('code.location.tile.tile')
local Machines = require('code.location.tile.building.machine.machines')
local Door = require('code.location.tile.building.door')
local Barricade = require('code.location.tile.building.barricade')
local Integrity = require('code.location.tile.building.integrity')

local Building = class('Building', Tile)

--[[
  FULL_NAME = 'insert name'
  BUILDING_TYPE = residential/government/industrial/commercial/generic
  door_missing = true/nil
  search_odds = {outside = num, inside = num}/nil  
  item_chance = {item = .00 chance}
--]]

--[[-----------  SEARCH ODDS  ------------ 

mall = 60%
PD, FD, hospital = 50%
factory = 30-40%
library/school = 20%
home = 10%

--]]-----------  SEARCH ODDS  ------------

local OUTSIDE_SEARCH_ODDS, INSIDE_SEARCH_ODDS = .50, .15

Building.BUILDING_TYPE = 'generic'
Building.search_odds = {OUTSIDE = OUTSIDE_SEARCH_ODDS, INSIDE = INSIDE_SEARCH_ODDS}
Building.item_chance = {
  outside = {
    -- WEAPONS =  00.1%
    Knife = .001,

    -- MISC   =  09.9%
    Newspaper = .099,

    -- EQUIPMENT =  90%
    Barricade = .90,  
  },  
  inside =  {
   -- MEDICAL =  15%
          FAK = .05,
      Bandage = .10,

   -- WEAPONS =  30%
       Pistol = .03,
      Shotgun = .02,
          Bat = .15,
        Knife = .10,

      -- MISC =  40%
    Newspaper = .10,
         Book = .15,
       Bottle = .15,

      -- GEAR =  15%
        Radio = .05,
        Phone = .10, 
  }
}

function Building:initialize(map, y, x, name)
  Tile.initialize(self, map, y, x, name)  
  self.inside_players = {}
  
  self.door        = Door:new(self)
  self.barricade   = Barricade:new(self)
  self.integrity   = Integrity:new(self) 
end

function Building:insert(player, setting) 
  if setting == 'inside' then self.inside_players[player] = true 
  elseif setting == 'outside' or setting == nil then self.outside_players[player] = true
  end
end

function Building:remove(player, setting) 
  if setting == 'inside' then self.inside_players[player] = nil  
  elseif setting == 'outside' or setting == nil then self.outside_players[player] = nil 
  end
end

function Building:install(machine, condition) 
  local Machine = machine:sub(1,1):upper()..machine:sub(2)  -- capitalize machine
  self[machine] = Machines[Machine]:new(self, condition) 
end

function Building:blackout()
  -- 3x3 area do blackout event on tile(s)
end

function Building:getBarrier() return (self.barricade:getHP() > 0 and 'barricade') or (self.door:getHP() > 0 and 'door') end  -- should this be a class?

function Building:getEquipment()
  local machines = {}
  for Machine in ipairs(Machines) do
    machine = string.lower(tostring(Machine))
    if self[machine] then machines[#machines+1] = self[machine] end
  end
  return machines
end

function Building:getMachine(machine) return self[machine] end

-- function Building:getPos() return (NO NEED?)

function Building:isPresent(setting)
  if setting == 'machines' then
    for Machine in ipairs(Machines) do
      machine = string.lower(tostring(Machine))
      if self[machine] then return true end
    end
    return false
  elseif setting == 'powered machines' then 
    return self:isPresent('machines') and self:isPowered()
  elseif setting == 'damaged machines' then
    for Machine in ipairs(Machines) do
      machine = string.lower(tostring(Machine))
      if self[machine] and self[machine]:isDamaged() then return true end
    end
    return false
  elseif setting == 'door' then
    return self.door and true or false
  elseif setting == 'damaged door' then
    return (self.door and self.door:isDamaged()) or false
  else -- individual machine
    local machine = setting
    return self[machine]
  end
end

-- function Building:isOccupied(mob_type)  great way to check for people inside when ruining

function Building:isFortified() return self.barricade:getHP() > 0 and self.door:getHP() > 0 end

function Building:isPowered() return self.generator and self.generator:isActive() end

function Building:isOpen() return self.barricade:isDestroyed() and (self.door:isOpen() or self.door:isDestroyed()) end

function Building:updateHP(num) 
  if self:getBarrier() == 'barricade' then 
    self.barricade:updateHP(num) 
  else -- self:getBarrier() == 'door'
    self.door:updateHP(num) 
  end
end

return Building