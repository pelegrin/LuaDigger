-- Maze --
-- 08/01/2012 pelegrin
-- class implemented Maze
-----------------------------------

Maze = class()

function Maze:init()
 --   self.rocks = {} --no rocks at this time
    self.gems = {}
    self.mazeBlocks = {}
    self.size = nil
end

function Maze:setOpacity(opacity)
    if not self.size then return end
    for i = 1,self.size do
        self.mazeBlocks[i]:setOpacity(opacity)
    end    
end


function Maze:loadLevel(levelMap)
    self.size = #levelMap
    --clear gems and rocks structure
    self.gems = {} 
--    self.rocks = {}
    for i = 1,#levelMap do
        if levelMap[i] >= GEMTYPE.ORANGE then
            levelMap[i] = levelMap[i] - GEMTYPE.ORANGE
            table.insert(self.gems,Gem(i,GEMTYPE.ORANGE))
        elseif levelMap[i] >= GEMTYPE.GREEN then
            levelMap[i] = levelMap[i] - GEMTYPE.GREEN
            table.insert(self.gems,Gem(i,GEMTYPE.GREEN))
        elseif levelMap[i] >= GEMTYPE.BLUE then
            levelMap[i] = levelMap[i] - GEMTYPE.BLUE
            table.insert(self.gems,Gem(i,GEMTYPE.BLUE))
        end
        self.mazeBlocks[i] = MazeBlock(levelMap[i], numberToXY(i))
    end
end

function Maze:getGemsNumber()
    if self.gems == nil or #self.gems == 0 then
        return 0 
    else
        return #self.gems
    end
end
--return type of block and boolean if there is a gem in this block
function Maze:getBlockType(number)
    if not number or number < 1 or number > NBLOCKS * NBLOCKS then return TYPES.WALL,false end
    local isGemHere = false
    for i = 1,#self.gems do
       if self.gems[i]:getNumber() == number then
            isGemHere = true
            break;
       end      
    end
    return self.mazeBlocks[number].type,isGemHere
end

function Maze:eat(number)
    return self.mazeBlocks[number]:eat()    
end

function Maze:eatGem(number)  
    for i = 1,#self.gems do
        if self.gems[i]:getNumber() == number then
            self.gems[i]:collect()     
            break
        end
    end
end

function Maze:draw()
   -- pushMatrix()
   -- zLevel(0)
    -- draw line around maze
    rectMode(CENTER)
    --draw blocks
    strokeWidth(0)
    translate(1,1)
    for i = #self.mazeBlocks,1,-1 do
        self.mazeBlocks[i]:draw()
    end
    --draw rocks
    --[[
    for i,v in ipairs(self.rocks) do
        v:draw()
    end
    --]]
    --draw diamonds
    for i,v in ipairs(self.gems) do
        if v then
            if v.remove then
                table.remove(self.gems, i)
                --add points to the game
                GAME:addScore(v.type)
                if #self.gems == 0 then GAME:nextLevel() end
            else v:draw()
            end
        end    
    end
--    popMatrix() 
end

--general factory for using in iterator
-- part of BFS algorithm
-- mode - eater or normal mode (true = eater, false = normal)
function Maze:getAdjacent(v,mode)
    return recAdj,{self.mazeBlocks,v,mode},false
end

function recAdj(v,indx)
         local type = nil
         if not indx then 
            indx = v[2] - 1 --next west
            if indx < 1 or indx > NBLOCKS * NBLOCKS then return recAdj(v,indx) end
            rindx = math.ceil(indx/NBLOCKS)
            rv =  math.ceil(v[2]/NBLOCKS)
            type = v[1][indx].type
            if not v[3] and rindx == rv and type == TYPES.EMPTY then
                return indx, v
            elseif v[3] and rindx == rv 
                   and (type == TYPES.EMPTY or type == TYPES.DIRTY) then
                return indx, v
            end
            return recAdj(v,indx)
         end
         if (indx == v[2] - 1) then
              indx = v[2] + 1 --next east
            if indx < 1 or indx > NBLOCKS * NBLOCKS then return recAdj(v,indx) end
              rindx = math.ceil(indx/NBLOCKS)
              rv =  math.ceil(v[2]/NBLOCKS)
              type = v[1][indx].type            
              if not v[3] and rindx == rv and type == TYPES.EMPTY then 
                  return indx, v
              elseif v[3] and rindx == rv
                 and (type == TYPES.EMPTY or type == TYPES.DIRTY) then                    
                  return indx, v
                end
              return recAdj(v,indx)
         end
        if (indx == v[2] + 1) then 
            indx = v[2] + NBLOCKS --next north
            if indx < 1 or indx > NBLOCKS * NBLOCKS then return recAdj(v,indx) end
            type = v[1][indx].type
            if not v[3] and type == TYPES.EMPTY then
                return indx, v
            elseif v[3] and (type == TYPES.EMPTY or type == TYPES.DIRTY) then
                return indx, v
            end
        return recAdj(v,indx)
        end
        if (indx == v[2] + NBLOCKS) then 
            indx =  v[2] - NBLOCKS --next south
            if indx < 1 or indx > NBLOCKS * NBLOCKS then return nil end
            type = v[1][indx].type
            if not v[3] and type == TYPES.EMPTY then
                return indx, v
            elseif v[3] and (type == TYPES.EMPTY or type == TYPES.DIRTY) then
                return indx, v    
            end
        end
        return nil
end

