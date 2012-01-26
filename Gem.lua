-- Gem --
-- 29/12/2011 pelegrin
-- class implemented all gems in game
-----------------------------------

Gem = class()

function Gem:init(number, type)
    self.pos = vec2(numberToXY(number))
    self.number = number
    self.type = type
    self.collected = nil
    self.remove = false
end

function Gem:getNumber()
    return self.number
end

function Gem:draw()
    if self.collected then
        local isFinish
        self.pos, isFinish = self.collected()
        if isFinish then self.remove = true self.collected = nil end
    end
    if self.type == GEMTYPE.ORANGE then
        sprite("Planet Cute:Gem Orange",self.pos.x, self.pos.y + 10, 0.8 * SIZE)
    elseif self.type == GEMTYPE.GREEN then
        sprite("Planet Cute:Gem Green",self.pos.x, self.pos.y + 10, 0.8 * SIZE)
    else --default BLUE
        sprite("Planet Cute:Gem Blue",self.pos.x, self.pos.y + 10, 0.8 * SIZE)
    end
end

function Gem:collect()
    if self.collected or self.remove then return end
    sound(SOUND_JUMP,1)
    self.collected = collectedAnimation(self.pos, GEMTARGET)
end

--input parameter target where gem is moving
function collectedAnimation(source, target)
    local delta = vec2((target.x - source.x)/30, (target.y - source.y)/30)
    return function()
        local isFinish = false
        source = source + delta
        if source:dist(target) < delta:len() then
            isFinish = true
        end
        return source, isFinish
    end
end
