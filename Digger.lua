-- Digger --
-- 
-----------------------------------

Digger = class()

function Digger:init()
   self.pos = nil
   self.target = nil
   self.velocity = 0
   self.currentNumber = nil
----------------------------
   self.shouldStop = false
   self.dying = nil
   self.isMovingX = nil -- true when moving on x, false when moving on y, nil when stop
   self.bombMode = false -- bomb mode for setting bomb
   self.validBombTargets = {}
end
--return vec with current coordinates
function Digger:getXY()
   return self.pos
end

function Digger:setDigger(number)
   self.pos = vec2(numberToXY(number))
   self.target = vec2(self.pos.x,self.pos.y)
   self.currentNumber = number
   self.velocity = 0
   self.dying = nil
end

function Digger:setBombMode()
   self.bombMode = not self.bombMode
   self.validBombTargets = {}
   if self.bombMode then self.shouldStop = true end
end

function Digger:getValidBombTargets()
   --copy table
   local result = {}
   for i = 2, #self.validBombTargets do table.insert(result,self.validBombTargets[i]) end
   return result
end

--called each frame to update position 
function Digger:update()
   if self.dying then return end --don't update digger while dying
   --handle bomb mode
   if self.bombMode and #self.validBombTargets < 1 then 
       --clear previous validBombTargets table
       self.validBombTargets = {true}
       --fill the validBombTargets table
       local sq = {}
       sq = GAME:getEmptyAround(self.currentNumber)
       for i = 1, #sq do table.insert(self.validBombTargets,sq[i]) end 
   end    
   if self.velocity == 0 then return end --digger is not moving
   if self.target:dist(self.pos) < 0.5 * MAX_SPEED then
   -- approaching final destination
           self.velocity = 0
           self.pos = vec2(self.target.x,self.target.y)
           self.currentNumber = XYToNumber(self.pos)            
           self.shouldStop = false
           self.isMovingX = nil 
           --we should fill bombTarget table for the last time
           if self.bombMode and #self.validBombTargets > 0 then 
           --clear previous validBombTargets table to query about bomb target next updat         
               self.validBombTargets = {}
           end    
           return
   end    
   --update digger coordinates
   if self.pos.x < self.target.x then
           previousNumber = XYToNumber(vec2(self.pos.x + SIZE/2,self.pos.y))
           self.pos.x = self.pos.x + self.velocity
           self.isMovingX = true
           self.currentNumber = XYToNumber(vec2(self.pos.x + SIZE/2,self.pos.y))
   elseif self.pos.x > self.target.x then
           previousNumber = XYToNumber(vec2(self.pos.x + 1 - SIZE/2,self.pos.y))
           self.pos.x = self.pos.x - self.velocity
           self.isMovingX = true            
           self.currentNumber = XYToNumber(vec2(self.pos.x - SIZE/2,self.pos.y))
   elseif self.pos.y < self.target.y then
           previousNumber = XYToNumber(vec2(self.pos.x,self.pos.y + SIZE/2)) 
           self.pos.y = self.pos.y + self.velocity
           self.isMovingX = false            
           self.currentNumber = XYToNumber(vec2(self.pos.x,self.pos.y + SIZE/2))
   elseif self.pos.y > self.target.y then
           previousNumber = XYToNumber(vec2(self.pos.x,self.pos.y + 1 - SIZE/2)) 
           self.pos.y = self.pos.y - self.velocity
           self.isMovingX = false            
           self.currentNumber = XYToNumber(vec2(self.pos.x,self.pos.y - SIZE/2))
   end
   if self.shouldStop then self.target = vec2(numberToXY(self.currentNumber)) end
   if previousNumber == self.currentNumber then return end -- query block type only when
   -- crossing block             
   blockType, isGemHere = GAME:getBlockType(self.currentNumber)
   if  blockType == TYPES.DIRTY then
       GAME:eat(self.currentNumber)
       self.velocity = 0.40 * MAX_SPEED
       if isGemHere then GAME:eatGem(self.currentNumber) end
       if self.bombMode then GAME:prepareForSetBomb() end
   elseif blockType == TYPES.EMPTY then 
       self.velocity = 0.6 * MAX_SPEED
       if isGemHere then GAME:eatGem(self.currentNumber) end
       if self.bombMode then GAME:prepareForSetBomb() end
   elseif blockType == TYPES.WALL then
       self.velocity = 0
       self.pos = vec2(numberToXY(previousNumber))
       self.target = vec2(numberToXY(previousNumber))
       self.currentNumber = previousNumber
       self.isMovingX = nil
   end
   --[[       
   if self.bombMode and #self.validBombTargets > 0 then 
       --clear previous validBombTargets table to query about bomb target next update
       self.validBombTargets = {}
   end 
   --]]   
end

function Digger:kill()
   if not self.dying then self.dying = die() end
end    

function Digger:draw()
   if not self.pos then return end --digger not set by game
   if self.dying then
       local visible, count = self.dying()
       if not visible then tint(255, 0, 0, 255) else tint(255, 0, 0, 0) end
   end
   if DEBUG then 
       if self.target then 
           fill(25, 246, 93, 160)
           rect(self.target.x,self.target.y,SIZE,SIZE)
           fill(59, 89, 195, 176)
           rect(self.pos.x,self.pos.y,SIZE,SIZE)
       end 
   end
   if self.bombMode then
       -- fill nearest empty squares
       -- first element is true in case we invoke getAround function
       for i = 2, #self.validBombTargets do 
           fill(223, 51, 51, 150)
           local sq = vec2(numberToXY(self.validBombTargets[i]))
           rect(sq.x, sq.y,SIZE,SIZE) 
       end    
   end
   sprite("Planet Cute:Character Boy", self.pos.x, self.pos.y + 10,SIZE)
end

-- this function set a target according to touch coordinate
function Digger:move(x,y)
   if self.dying then return end -- don't move during dying
   local touchNumber = XYToNumber(vec2(x,y))
   local targetNumber = XYToNumber(self.target)
   if targetNumber == touchNumber then return end -- touch on target
   local currentNumber = XYToNumber(self.pos)
   if touchNumber == currentNumber then
   -- stop if touch digger        
       self.shouldStop = true
       return
   end
   local touchPos = vec2(numberToXY(touchNumber))
   deltaX = math.abs(touchPos.x - self.pos.x)
   deltaY = math.abs(touchPos.y - self.pos.y)
   if self.isMovingX == nil then
       if deltaX > deltaY then
           --set target on x
           self.target = vec2(touchPos.x,self.pos.y)
       else 
           --set target on y
           self.target = vec2(self.pos.x,touchPos.y)
       end    
   elseif self.isMovingX == true then
       --set target on x
       self.target = vec2(touchPos.x,self.pos.y)
   else
       --set target on y
       self.target = vec2(self.pos.x,touchPos.y)
   end    
   if self.velocity == 0 then 
       self.velocity = 0.6 * MAX_SPEED 
   end    
end

-- utility function for creating blinking effect (via clousure)
function die()
   local _visible = true
   local frame_count = 5
   local count = 8
   return
   function ()
       frame_count = frame_count -1
       if frame_count == 0 then
           count = count - 1
           _visible = not _visible
           frame_count = 5
       end 
       return _visible, count    
   end
end  