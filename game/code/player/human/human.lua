local class = require('code.libs.middleclass')
local Skills = require('code.player.skills')
local Inventory = require('code.player.human.inventory')
local Fist = require('code.player.human.organic_weaponry')
local Carcass = require('code.player.human.carcass')
local Network = require('code.player.human.network')
local human_skill_list = require('code.player.human.skill_list')
local human_action_list = require('code.player.human.action.actions')
local Player = require('code.player.player')
local names = require('code.player.names.names')

local Human = class('Human', Player)

Human.action_list = human_action_list

local default_IP= 0

function Human:initialize(username, ...) --add account name
  self.username = username or names:generateRandom('zombie')
  self.ip = default_IP
  self.inventory = Inventory:new(self)
  self.skills = Skills:new(human_skill_list)
  self.network = Network:new(self)
  
  Player.initialize(self, ...)  
end

function Human:killed()
  self.carcass = Carcass:new(self)
  -- Corpse:new()   ???
  -- we need to create a carcass for zombies to feed on, then afterwards create a new Zombie instance from the carcass? (pass useful human data as args to corpse)
  -- But we need to retain all info for the player to see next time they log in, (so they can witness their gory death)
  -- need to also update status_effects so that trackers lose their scents, etc.
  self:permadeath()   -- deletes human instance... not quite... delete player from controling human instance
end

--[[
---  TAKE [X]
--]]

-- client-side functions

function Human:getWeapons()
  local list = {{weapon=Fist}} -- organic   

  for inv_ID, item in ipairs(self.inventory) do
    if item:isWeapon() then list[#list+1] = {weapon=item, inventory_ID=inv_ID} end  
  end          
  return list
end  

function Human:getTargets(mode)
  local targets = {}
  
  local p_tile, setting = self:getTile(), self:getStage()
  local all_players = p_tile:getPlayers(setting) -- maybe get only zombie targets instead of all?
  
  for player in pairs(all_players) do 
    if player:isStanding() and player ~= self then targets[#targets+1] = player end 
  end 
  
  return targets
end

return Human