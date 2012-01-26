-- Bug --
-- 29/12/2011 pelegrin
-----------------------------------

Bug = class()

--parameters: position(vec2), type of Bug (depends behavior and viewDistance) and
--guard path for guard bug only
function Bug:init(v, type, guardpath)
    self.pos = v
    -- here we store next step
    self.target = v
    -- table of blocks to target
    self.path = {}
    self.velocity = 0
    -- indicator, that digger have been seen
    self.angry = false
    --wait function if there is no target (around 2 sec)
    self.wait = nil
  -- self.freeze = false -- used during game transition
    self.type = type
    if not type or type == BUGTYPE.SMALLY then
        self.viewDistance = 3     -- sensitive distance, it can "see" a digger at this distance
        self.eater = eaterTimer(240,90) -- eater mode, can eat ground blocks; 30 tick per second
    elseif type == BUGTYPE.MEDY then
        self.viewDistance = 4
        self.eater = eaterTimer(200,110)
    elseif type == BUGTYPE.BIGGY then
        self.viewDistance = 6
        self.eater = eaterTimer(180,150)    
    end    
end
--[[
function Bug:tofreeze()
    self.freeze = true
end
--]]
--[[
function Bug:unfreeze()
    self.freeze = false
end
--]]
function Bug:draw()
    if self.angry then tint(255, 93, 0, 161) end
--    if self.freeze then tint(255, 255, 255, 100) end
    --[[
    if #self.path > 0 then
        -- highligth target
        fill(255, 5, 0, 150)
        local t = vec2(numberToXY(self.path[1]))
        rect(t.x,t.y,SIZE,SIZE)
    end
    --]]
    if self.type == BUGTYPE.SMALLY then
        sprite("Planet Cute:Enemy Bug",self.pos.x, self.pos.y + 10,SIZE)
    elseif self.type == BUGTYPE.MEDY then
        sprite("Tyrian Remastered:Evil Head",self.pos.x, self.pos.y + 10,SIZE)
    elseif self.type == BUGTYPE.BIGGY then
        sprite("Tyrian Remastered:Blimp Boss",self.pos.x, self.pos.y + 10,SIZE)
    else 
        sprite("Planet Cute:Enemy Bug",self.pos.x, self.pos.y + 10,SIZE)
    end                
end

function Bug:update()
  --  if self.freeze then return end -- don't update during freeze
    local mode = self.eater()
    if (self.wait and self.wait()) then return end
    if (self.wait and not self.wait()) then self.wait = nil end
    if (self.velocity > 0 and self.target:dist(self.pos) <  2 * self.velocity) then
    -- approaching final destination
            self.velocity = 0
            self.pos = self.target
            return
    end
    if (self.pos ~= self.target) then
        -- simple go to target (this is next column or row)
        -- local currentNumber = XYToNumber(self.pos)
        if self.pos.x > self.target.x
            and math.abs(self.pos.x - self.target.x) > self.velocity then
                previousNumber = XYToNumber(vec2(self.pos.x + 1 - SIZE/2,self.pos.y))
                self.pos.x = self.pos.x - self.velocity
                currentNumber = XYToNumber(vec2(self.pos.x - SIZE/2,self.pos.y))
        elseif self.pos.x < self.target.x
               and math.abs(self.pos.x - self.target.x) > self.velocity then
                    previousNumber = XYToNumber(vec2(self.pos.x + SIZE/2,self.pos.y)) 
                    self.pos.x = self.pos.x + self.velocity
                    currentNumber = XYToNumber(vec2(self.pos.x + SIZE/2,self.pos.y))
        elseif self.pos.y > self.target.y
                and math.abs(self.pos.y - self.target.y) > self.velocity then
                previousNumber = XYToNumber(vec2(self.pos.x,self.pos.y + 1 - SIZE/2)) 
                self.pos.y = self.pos.y - self.velocity
                currentNumber = XYToNumber(vec2(self.pos.x,self.pos.y - SIZE/2))
        elseif self.pos.y < self.target.y
                and math.abs(self.pos.y - self.target.y) > self.velocity then
                    previousNumber = XYToNumber(vec2(self.pos.x,self.pos.y + SIZE/2)) 
                    self.pos.y = self.pos.y + self.velocity
                    currentNumber = XYToNumber(vec2(self.pos.x,self.pos.y + SIZE/2))
        end
        -- collision detection
        local diggerPos = GAME:getDigger()
        if self.pos:dist(diggerPos) < SIZE then
            GAME:killDigger()
        end           
        --if currentNumber == XYToNumber(GAME:getDigger()) then GAME:killDigger() end
        if previousNumber == currentNumber then return end -- check the same square
        if mode and GAME:getBlockType(currentNumber) == TYPES.DIRTY then
            GAME:eat(currentNumber)
            self.velocity = 0.3 * MAX_SPEED
        end
        if not mode and GAME:getBlockType(currentNumber) == TYPES.DIRTY then
            GAME:eat(currentNumber)
            self.velocity = 0.3 * MAX_SPEED
            self.path = {} -- clear eater path
        end
        return
    end
    local nextTarget = table.remove(self.path)
    if not nextTarget then
        self.path, self.angry = GAME:LookingAround(self.pos,self.viewDistance, mode)
        if #self.path < 1 then self.wait = wait(1) end
    else
        if not self.angry and probability(0.3) then
         -- locking around during moving on path
            tempPath, angry = {}, false
            tempPath, angry = GAME:LookingAround(self.pos,self.viewDistance, mode)
            if angry then self.path = tempPath self.angry = angry end
        end 
        --set target
        --convert result (number in maze) to vec2
        self.target = vec2(numberToXY(nextTarget))
        self.velocity = not self.angry and 0.4 * MAX_SPEED or 0.65 * MAX_SPEED
    end        
end
