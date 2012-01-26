--Main
--Global constants
GAME = nil
MAXWIDTH = WIDTH - 50
MAXHEIGHT = WIDTH - 50
NBLOCKS = 16
TYPES = {EMPTY = 0, DIRTY = 1, WALL = 2, BUG = 3, DIGGER = 9}
SIZE = MAXWIDTH/NBLOCKS
MAX_SPEED = 10
BUGTYPE = {SMALLY = 3, MEDY = 4, POISY = 5, BIGGY = 6, GUARD = 7}
GEMTYPE = {BLUE = 10,GREEN = 20, ORANGE = 30}
GEMTARGET = vec2(MAXWIDTH - 2 * SIZE, HEIGHT - SIZE/2)
OFFSET = SIZE/3

--
DEBUG = false
-- Use this function to perform your initial setup
function setup()
    --setInstructionLimit(0)
    GAME = Game()
    GAME:start()
end

-- This function gets called once every frame
function draw()
    GAME:update()
    GAME:draw()
end


function touched(touch)
    if (touch.state == BEGAN or touch.state == MOVING) and
    touch.x > 0 and touch.x < MAXWIDTH and
    touch.y > 0 and touch.y < MAXHEIGHT then
        if GAME.isBombSetting then
            GAME:setBomb(touch)
        else GAME:moveDigger(touch.x, touch.y)
        end
    elseif touch.state == BEGAN and touch.x > MAXWIDTH + 0.1 * SIZE and
            touch.x < MAXWIDTH + 1.1 * SIZE and touch.y > 0 and touch.y < SIZE then
        GAME:prepareForSetBomb()
    end
end
-----------------------------------
-- Utility Functions --
-----------------------------------

-- return: true or false with probability p [0,1). if p = 0 always return false, p = 1 always true
function probability(p)
    return math.random() < p
end

-- return: position in array with probability that is value of array
-- sum of all elements must be less then or equal then 1 (resolution in .x)
function roll(pArray)
    local i, sum = math.random(100),0;
    for j = 1,#pArray do
        sum = sum + pArray[j] * 100
        if (i > 0 and i <= sum) then return j end
    end
    return 0 -- in case of empty array
end

-- function for convert number in maze to x,y coordinates (lower left corner)
-- input: number in maze
-- return: x,y coordinate
function numberToXY(number)
    if not number then return 0,0 end -- for safety return origin
    local row = math.ceil(number/NBLOCKS)
    local column = (number%NBLOCKS == 0 and NBLOCKS) or number%NBLOCKS
    return (column - 0.5)*SIZE, (row - 0.5)*SIZE
end

-- function for convert x,y coordinates (lower left corner) to number in maze
-- input: vec2 
-- return: number in maze
function XYToNumber(v)
   return (math.ceil(v.y/SIZE) - 1)*NBLOCKS + math.ceil(v.x/SIZE) 
end

-- wait timer in sec
function wait(timer)
    local counter = timer * 30 -- assume frame rate is 1/30
    return function()
        counter = counter - 1
        if counter <= 0 then return false end
        return true
    end
end

-- timer for eater mode
-- timerNormal - time in ordinary bug mode, timerEater - time in eater mode
function eaterTimer(timerNormal, timerEater)
    local counter = timerNormal
    local mode = false -- eater mode, if true we are in eater mode, otherwise in normal mode
    return function()
        counter = counter - 1
        if counter <= 0 then 
            mode = not mode
            if mode then counter = timerEater
            else counter = timerNormal
            end
        end
        return mode    
    end
end

-- borrow from open source projects
-----------------------------------
-- Functions for drawing numbers --
-----------------------------------

-- Draw a number. x, y is top left
function number(x, y, n, w)
    l = string.len(n)
    for i = 1, l do
        drawDigit(x + ((i - 1) * (w * 1.5)), y, string.sub(n, i, i), w)
    end
end

-- Draw a single digit
function drawDigit(x, y, n, w)
    h = 2 * w
    if string.match(n, "1") then
        line(x + (w / 2), y, x + (w / 2), y - h)
    elseif string.match(n, "2") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - (h / 2))
        line(x + w, y - (h / 2), x, y - (h / 2))
        line(x, y - (h / 2), x, y - h)
        line(x, y - h, x + w, y - h)
    elseif string.match(n, "3") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
        line(x + w, y - h, x, y - h)
        line(x, y - (h / 2), x + w, y - (h / 2))
    elseif string.match(n, "4") then
        line(x, y, x, y - (h / 2))
        line(x, y - (h / 2), x + w, y - (h / 2))
        line(x + w, y, x + w, y - h)
    elseif string.match(n, "5") then
        line(x + w, y, x, y)
        line(x, y, x, y - (h / 2))
        line(x, y - (h / 2), x + w, y - (h / 2))
        line(x + w, y - (h / 2), x + w, y - h)
        line(x + w, y - h, x, y - h)
    elseif string.match(n, "6") then
        line(x + w, y, x, y)
        line(x, y, x, y - h)
        line(x, y - h, x + w, y - h)
        line(x + w, y - h, x + w, y - (h / 2))
        line(x + w, y - (h / 2), x, y - (h / 2))
    elseif string.match(n, "7") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
    elseif string.match(n, "8") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
        line(x + w, y - h, x, y - h)
        line(x, y - h, x, y)
        line(x, y - (h / 2), x + w, y - (h / 2))
    elseif string.match(n, "9") then
        line(x + w, y - (h / 2), x, y - (h / 2))
        line(x, y - (h / 2), x, y)
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
        line(x + w, y - h, x, y - h)
    elseif string.match(n, "0") then
        line(x, y, x + w, y)
        line(x + w, y, x + w, y - h)
        line(x + w, y - h, x, y - h)
        line(x, y - h, x, y)
    elseif string.match(n, "x") then
        line(x, y - (w / 3), x + w, y - (h + 1))
        line(x + w, y - (w / 3), x, y - (h + 1))
    end
end
