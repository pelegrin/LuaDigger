-- Game --
-- 29/12/2011 pelegrin
-- main class, implemented game itself
-----------------------------------

Game = class()
MAXLIVE = 5 -- maximum allowed lives in game

function Game:init()
    self.currentLevel = 1
    self.lives = 3 -- number of lives at the begining
    self.scores = 0 -- scores in game
    self.bugs = {}        
    self.maze = Maze()
    self.digger = nil
    self.bombs = 3 -- initial number of bombs
    self.explosionMaker = {} 
    self.isBombSetting = false
----------------------------    
    self.transite = nil --transition between states in game
end


function Game:start()
    --make half transition (black to full opacity) to begin a game
--    self.explosionMaker = ExplosionMaker()    
    self.transite = transition(true)
end

function Game:nextLevel()
    self.currentLevel = self.currentLevel + 1 
    self.transite = transition()        
end

-- must be a private 
function Game:prepareGame()
    local levelManager = LevelManager(self.currentLevel)
    self.maze:loadLevel(levelManager:getLevel())
    self.digger = levelManager:getDigger()
    self.bugs = levelManager:getBugs()    
end            

function Game:update()
    if not self.transite then        
        if self.digger then self.digger:update() end
        for i=1,#self.bugs do self.bugs[i]:update() end
        for i=1, #self.explosionMaker do
            if self.explosionMaker[i]:isFinish() then table.remove(self.explosionMaker,i) 
            else self.explosionMaker[i]:update() end
        end
    end
end

function Game:draw()
    background(0,0,0,255)
    if self.transite then
        local transite = self.transite()
        if transite == false then
            -- end of wait transition
            self.transite = nil
            self:restartLevel()
        elseif transite == true then local a = 0 --noop
        else 
            self.maze:setOpacity(transite)
            tint(255,255,255,transite)                    
        end 
    end
    --draw maze, digger and bugs
    self.maze:draw()
    if self.digger then self.digger:draw() end
    for i=1,#self.bugs do self.bugs[i]:draw() end
    -----------------------------------------
    -- draw static game information scores, lives and other things
    if self.currentLevel ~= END_LEVEL then
        pushMatrix()
        resetMatrix()
        stroke(255)
        strokeWidth(7)
        --draw scores        
        number(45, HEIGHT - SIZE/2 + 10, self.lives, SIZE/4)
        tint(255, 255, 255, 255) --to neglect previous effect of tint
        --draw number of lives
        sprite("Planet Cute:Character Boy", 
        60 - SIZE, HEIGHT - SIZE/2 + 8, SIZE)
        sprite("Planet Cute:Gem Blue", MAXWIDTH - 2 * SIZE, HEIGHT - SIZE/2, SIZE/1.5)
        number(MAXWIDTH - 1.4 * SIZE, HEIGHT - SIZE/2 + 4, self.scores, SIZE/4)
        -- draw bomb and number of active bombs
        for i = 1, #self.explosionMaker do self.explosionMaker[i]:draw() end
        if self.isBombSetting and self.bombs > 0 then tint(199, 61, 33, 245) end
        number(MAXWIDTH + 0.5 * SIZE, 1.5 * SIZE, self.bombs, SIZE/6) 
        sprite("Tyrian Remastered:Mine Spiked Huge", MAXWIDTH + 0.6 * SIZE, 0.5 * SIZE, SIZE, SIZE)
        popMatrix()
    end
end        

-- invoked by bugs and digger
function Game:getBlockType(number)
    if DEBUG then print("Get Block type") end
    return self.maze:getBlockType(number)
end   

-- invoked by bugs
function Game:getDigger()
    if self.digger then return self.digger:getXY() end
    return nil
end    

-- invoked by digger
function Game:eat(number)
    return self.maze:eat(number)
end

-- invoked by digger 
function Game:eatGem(number)
    return self.maze:eatGem(number)
end

-- invoked by event loop
function Game:moveDigger(x,y)
    if self.transite then return end
    return self.digger:move(x,y)
end

-- invoked by bug
function Game:killDigger()
    self.digger:kill()
    self.transite = wait(2)
    --for i=1,#self.bugs do self.bugs[i]:tofreeze() end
end

function Game:restartLevel()
    self.lives = self.lives - 1
    if self.lives == 0 then
        self.currentLevel = END_LEVEL
        self.transite = transition()
        return
    end
    --maze is the same, init digger, init bugs
    local levelManager = LevelManager(self.currentLevel)
    self.digger = levelManager:getDigger()
    self.bugs = levelManager:getBugs()    
end

-- invoked by gem at the end of moving
function Game:addScore(n)
    self.scores = self.scores + n
end

--private utility function for transition effect: fade out - black - fade in
-- (implement via closure)
-- must be local
function transition(isHalfTransition)
    local fade_timer = 20
    local black_timer = 10
    local isHalf = isHalfTransition or false --from black to full opaque or from full to full
    local isHalfDone = false
    return function ()
        if isHalf and black_timer ~= 0 then fade_timer = 0 end
        if fade_timer == 0 then
            black_timer = black_timer - 1
            if black_timer > 0 then return 0 end -- full transparent
            if isHalfDone then
                GAME.transite = nil
                return 255
            end
            GAME:prepareGame()
            --end of transition, return full opaque
            --reverse transition here, set the timer
            fade_timer = 20
            isHalfDone = true
        else fade_timer = fade_timer - 1
        end
        if isHalfDone then return 255 * (1 - fade_timer/20) -- fade in
        else return 255 * fade_timer/20 end --fade out
    end 
end

-- FIFO implementation
function Queue()
    local _queue, _impl = {},{}
    _queue.enqueue = function (el)
        --check for nil value
        if not el then return end
        table.insert(_impl,el)
     end
    _queue.dequeue = function ()
--        if not _impl[1] then return nil end
        return table.remove(_impl,1)
    end
    _queue.isEmpty = function ()
        if table.getn(_impl) < 1 then return true end
        return false
    end           
    return _queue
end


-- return table with numbers of empty squares around input parameter
function Game:getEmptyAround(number)
    local result = {}
    for el in self.maze:getAdjacent(number,false) do table.insert(result,el) end
    return result    
end    

-- BFS algorithm for finding shortest path
-- find target or digger and return table with shortest path from source to target or empty table
function Game:LookingAround(pos,view,mode)
    if DEBUG then print ("Loocking around") end
    local source = XYToNumber(pos)
    local marked, edges, queue = {}, {}, Queue()
    local count = 0
    local target = nil
    local isSee = false
    local diggerNum = XYToNumber(self.digger:getXY()) --digger number in maze
    if mode then        
        target = diggerNum
        isSee = true
    end
 
    --initialize marked, edges
    for i = 1,NBLOCKS * NBLOCKS do
        marked[i] = false
        edges[i] = false
    end
    queue.enqueue(source)
    while (not queue.isEmpty()) do
        local v = queue.dequeue()
        for el in self.maze:getAdjacent(v,mode) do
            if not marked[el] then
                marked[el] = true
                edges[el] = v
                count = count + 1
                if el == target then break end --found target
                queue.enqueue(el)
            end                    
        end
    end
    -- define target 
    local rdigger = math.ceil(diggerNum/NBLOCKS) -- digger row
    local rsource = math.ceil(source/NBLOCKS) -- bug row
    local cdigger = diggerNum%NBLOCKS -- digger column
    local csource = source%NBLOCKS -- source column
    local distance = math.abs(diggerNum - source)
    if not target and rdigger == rsource and  distance <= view and probability(0.9) then
        -- see digger on horizontal
        target = diggerNum
        isSee = true
    end
    if  not target and cdigger == csource and distance <= view*NBLOCKS and probability(0.9) then
        -- see digger on vertical
        target = diggerNum
        isSee = true
    end
    if not target and probability(0.35) then -- feel digger 
        target = diggerNum
        isSee = false
    end 
    -- in case we don't see digger we need to find a target
    -- trying to find marked direction far from source
    local direction = (probability(0.5) and 1) or -1
    local isOnepass, isFinish = false, false
    while not target and not isFinish do
        local endcount = (direction > 0 and NBLOCKS * NBLOCKS) or 1
        for i = source + direction,endcount,direction do
            if marked[i] and probability(1.7/count) then
                -- we make a choice
                target = i
                isFinish = true
                break                    
            end
        end
        if isOnepass then 
            isFinish = true
            if not target then target = source end
        else
            isOnepass = true
            direction = (direction > 0 and -1) or 1 --change direction
        end
    end
    --here we have a shortest path in edges
    if not marked[target] then return {},isSee end    
    local result, i = {}, target
    while i ~= source do
        table.insert(result,i)
        i = edges[i]
    end
    return result,isSee
end

function Game:addBomb(number)
    self.bombs = self.bombs + number
end

function Game:prepareForSetBomb()
    if self.bombs == 0 then return end
    self.isBombSetting = not self.isBombSetting
    if self.digger then self.digger:setBombMode() end
end    

function Game:setBomb(pos)
    if not self.digger then self:prepareForSetBomb() return end
    local touchNumber = XYToNumber(pos)
    local sq = self.digger:getValidBombTargets()
    for i = 1, #sq do
        if touchNumber == sq[i] then
            self.bombs = self.bombs - 1
            local exp = ExplosionMaker() 
            exp:explode(vec2(numberToXY(touchNumber)))
            table.insert(self.explosionMaker,exp)
            break   
        end    
    end
    self.isBombSetting = not self.isBombSetting
    if self.digger then self.digger:setBombMode() end
end
