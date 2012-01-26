-- Level Manager --
-- 29/12/2011 pelegrin
-- contains all levels  in game, can parse format of level
-----------------------------------


LevelManager = class()
END_LEVEL = 0
LEVELS = {}
--end of game level.  simple end  word
LEVELS[END_LEVEL] = {
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,2,2,2,0,2,0,0,0,2,0,2,2,0,0,0,
                    0,2,0,0,0,2,0,0,0,2,0,2,0,2,0,0,
                    0,2,0,0,0,2,0,0,2,2,0,2,0,0,2,0,
                    0,2,2,2,0,2,0,2,0,2,0,2,0,0,2,0,
                    0,2,0,0,0,2,2,0,0,2,0,2,0,0,2,0,
                    0,2,0,0,0,2,0,0,0,2,0,2,0,2,0,0,
                    0,2,2,2,0,2,0,0,0,2,0,2,2,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    }
LEVELS[1] = {
            11,21,21,2,0,0,3,1,2,1,1,0,0,0,0,1,
            1,1,2,0,0,0,0,1,1,1,1,2,0,30,30,0,
            1,1,2,0,0,0,0,1,2,1,1,2,0,0,0,0,
            1,1,1,0,0,0,0,1,2,11,11,1,0,0,0,0,
            1,2,1,0,0,0,0,1,1,2,2,0,0,0,0,4,
            1,1,9,0,0,1,1,1,1,1,1,0,1,1,2,1,
            1,1,1,0,2,2,2,1,1,1,1,0,1,1,1,1,
            2,2,2,0,1,1,1,1,1,1,1,0,2,1,1,1,
            1,1,2,0,2,1,2,1,1,1,1,0,2,1,1,1,
            1,11,2,0,2,1,2,1,1,1,1,0,2,1,1,1,
            1,11,2,0,2,1,2,2,2,2,2,0,1,1,1,1,
            1,31,2,0,2,11,21,21,2,1,0,0,2,2,2,1,
            1,2,2,0,2,2,2,2,2,1,0,2,1,11,11,2,
            1,1,1,3,0,0,0,0,0,0,0,0,1,1,1,1,
            1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
            1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
            }
LEVELS[2] = {
            6,0,0,2,0,0,10,10,2,1,1,0,0,0,0,3,
            1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,
            1,1,2,0,0,0,0,1,2,1,0,1,0,0,1,0,
            1,1,1,0,0,0,0,1,1,11,0,0,0,0,0,0,
            1,2,1,0,0,0,0,0,1,2,2,0,0,0,0,0,
            1,1,0,0,0,1,1,0,1,1,1,0,1,1,2,0,
            1,1,1,0,2,2,2,0,1,1,1,0,2,1,0,0,
            2,2,2,0,0,0,0,9,0,0,0,0,2,1,20,1,
            20,1,2,0,2,1,2,1,1,1,1,0,2,1,1,1,
            1,1,2,0,2,1,2,1,1,1,1,0,2,1,1,1,
            1,1,2,0,2,1,2,2,2,2,2,0,1,1,1,1,
            1,20,2,0,2,1,1,1,2,1,0,0,2,2,2,1,
            1,1,2,0,2,2,2,2,2,1,0,2,2,1,1,2,
            1,1,2,0,0,0,0,0,0,0,0,6,1,1,1,1,
            1,1,1,1,0,0,0,1,1,1,1,2,1,1,30,1,
            1,1,2,1,1,1,1,1,1,1,1,2,1,1,30,1
            }            
 -- input: current level       
function LevelManager:init(number)    
    self.level = {}
    self.bugs = {}
    self.digger = nil
    local currentLevel = LEVELS[number]
    if  currentLevel  == nil then currentLevel  =  LEVELS[END_LEVEL] end -- end of game
    for i = 1,#currentLevel do
        if TYPES.WALL >= currentLevel[i] or currentLevel[i] > TYPES.DIGGER then
            self.level[i] = currentLevel[i] --gems and other types
        elseif currentLevel[i] == TYPES.DIGGER then
            self.digger = i --only one digger ever possible
            self.level[i] = TYPES.EMPTY
        else
            -- here is only bugs left
            table.insert(self.bugs,{i,currentLevel[i]})
            self.level[i] = TYPES.EMPTY
        end --if    
    end
end

--return in Maze friendly format
function LevelManager:getLevel()
    return self.level
end
--return Digger, with set in right place
function LevelManager:getDigger()
    if not self.digger then return nil end
    local digger = Digger()
    digger:setDigger(self.digger)
    return digger
end

--return bug's table
function LevelManager:getBugs()
    local bugs = {} 
    for i = 1, #self.bugs do
        table.insert(bugs,Bug(vec2(numberToXY(self.bugs[i][1])), self.bugs[i][2]))
    end
    return bugs
end        
