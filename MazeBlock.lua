-- MazeBlock--
MazeBlock = class()

-- contsructor, type - type of Block, x,y - coordinate of lower left corner of block
function MazeBlock:init(type,x,y)
    self.type = type
    self.x = x
    self.y = y
    if (type == TYPES.EMPTY) then self.opacity = 0 
    else self.opacity = 255
    self.isEating = false
    end
end

function MazeBlock:getX()
    return self.x
end

function MazeBlock:getY()
    return self.y
end

function MazeBlock:setOpacity(opacity)
    self.opacity = opacity
end

function MazeBlock:draw()
    --rectMode(CENTER)
    if self.isEating then
        self.opacity = self.opacity - 18
        if self.opacity < 18 then
            self.opacity = 0
            self.isEating = false
            self.type = TYPES.EMPTY
        end    
    end    
    if self.type == TYPES.DIRTY then
        stroke(144,84,50,self.opacity)
        fill(144, 84, 50, self.opacity)
        rect(self.x,self.y,SIZE,SIZE)
    elseif self.type == TYPES.WALL then
        sprite("Planet Cute:Stone Block", self.x, self.y + OFFSET, SIZE)
    elseif self.type == TYPES.EMPTY then       
         --black rectangle
        fill(0, 0, 0, 255)
        rect(self.x,self.y,SIZE,SIZE)            
    end
end

function MazeBlock:eat()
    if self.isEating or self.type ~= TYPES.DIRTY then return end
    self.isEating = true
end
