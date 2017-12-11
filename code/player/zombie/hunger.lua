local class = require('code.libs.middleclass')
local dice = require('code.libs.dice')

local Hunger = class('Hunger')

local MAX_HUNGER = 1023

function Hunger:initialize(player)
  self.player = player
  self.hunger = 0
end

function Hunger:add(time) 	
  self.hunger = math.max(self.hunger + time, 0)

  if self.hunger >= MAX_HUNGER then
  	for i=1, MAX_HUNGER - self.hunger do 
	  	if dice.roll(10) == 1 then
	  	  return self.player:starve() -- game over pal
	  	end
	  end
	  self.hunger = MAX_HUNGER
	  local player = self.player   	  
	  player.log:append('You are starving!')
	end
end

function Hunger:elapse(time)
  self:add(time)
end

function Hunger:getHunger() return self.hunger end

return Hunger