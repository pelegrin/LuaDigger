--ExplosionMaker class
--borrow from twolivesleft.com and modifyed
--Globals
EASE_IN = 0
EASE_OUT = 1  
LONG_EASE_OUT = 2  
VERY_LONG_EASE_OUT = 3 
DELTA = 1/30
DURATION_FACT = 1

ExplosionMaker = class()

--constructor with coordinate 
function ExplosionMaker:init()
  self.pos = vec2(0,0) -- default position
  self.innerDelay = 0.4 * DURATION_FACT
  self.detailInnerDelay = 0.08 * DURATION_FACT
  self.started = false -- timer finished, explosion start
  self.finished = false -- finish current explosion
  self.timer = nil
  self.time = 0
  self.inner = CircularExpand(30)
  self.outer = CircularExpand(20)
  self.detailBits = CircularExpand(15)
  self.detailMask = CircularExpand(20)    
end

function ExplosionMaker:explode(pos)
 -- if (self.timer or self.started) and not self.finished then return end
  self.pos = pos        
  -- Configure
  self.outer.circleColor = color(255,100,0,255)
  self.detailBits.circleColor = color(255,100,0,255)
  self.detailMask.circleColor = color(255,255,255,255)
  self.inner.circleColor = color(255,255,255,200)    
  self.outer.easeMode = VERY_LONG_EASE_OUT
  self.inner.easeMode = VERY_LONG_EASE_OUT    
  self.detailBits.easeMode = VERY_LONG_EASE_OUT
  self.detailMask.easeMode = VERY_LONG_EASE_OUT        
  self.detailBits.startingSize = 2
  self.detailMask.startingSize = 5
  self.inner.startingSize = 10    
  self.detailBits.endingSize = 0.8 * SIZE
  self.detailMask.endingSize = 1.5 * SIZE
  self.outer.endingSize = 3 * SIZE
  self.inner.endingSize = 3.2 * SIZE    
  self.detailBits.speedFactor = 6
  self.detailMask.speedFactor = 7
  self.outer.speedFactor = 2
  self.inner.speedFactor = 5    
  self.outer.duration = 0.8 * DURATION_FACT
  self.inner.duration = 0.7 * DURATION_FACT
  self.detailBits.duration = 0.4 * DURATION_FACT
  self.detailMask.duration = 0.3 * DURATION_FACT
  --
  self.timer = wait(1.5)
   self.pulse = eaterTimer(0.5,1)
   self.soundpulse = eaterTimer(1,1)
  self.finished = false
end

function ExplosionMaker:draw()
  if self.timer then
       self.time = self.time + 0.5
      --draw bomb in position self.pos
       local size = self.pulse() and SIZE or 1.2 * SIZE + self.time
       sprite("Tyrian Remastered:Mine Spiked Huge", self.pos.x, self.pos.y, size, size)
  end
  if self.started then
  --draw explosion
    pushMatrix()
    pushStyle()
    ellipseMode(CENTER)
    smooth() 
    noStroke()
    translate(self.pos.x,self.pos.y)       
    self.outer:draw()
    self.inner:draw()
    self.detailBits:draw()
    self.detailMask:draw() 
    popStyle()
    popMatrix()
  end    
end

function ExplosionMaker:update()
-- 4 sec wait before explosion
  if self.timer then
       local isTimer = self.timer()
       if not isTimer then  
           self.timer = nil -- clear timer
           self.time = 0
           self.started = true
           sound(SOUND_EXPLODE,500)
           self.outer:explode()
       else if self.soundpulse() then sound(SOUND_HIT,1) end
       end    
  end    
  if not self.started then return end
  self.time = self.time + DELTA
  -- print("timer:"..self.time)             
  if not self.inner.started and self.time >= self.innerDelay then
       sound(SOUND_EXPLODE,10) 
      self.inner:explode()
      self.detailBits:explode()
  end      
  if not self.detailMask.started and self.time >= self.innerDelay + self.detailInnerDelay then
       sound(SOUND_EXPLODE,55) 
      self.detailMask:explode()
  end    
  self.outer:update()
  self.inner:update()
  self.detailBits:update()
  self.detailMask:update()    
  if self.inner.started == false and self.outer.started == false then self:finish() end    
end

function ExplosionMaker:isTimerActive()
  return self.timer
end

function ExplosionMaker:isFinish()
   return self.finished
end

function ExplosionMaker:finish()
  self.finished = true
  self.started = false
  self.time = 0
  self.timer = nil
end

--model
Circle = class()

function Circle:init(x,y,diameter)
  x = not x and 0 or x
  y = not y and 0 or y
  self.position = vec2(x,y)
  self.circleSize = diameter
  self.speed = 0
  self.startingSize = 0
  self.endingSize = 0
  self.direction = vec2(0, -1)
end


CircularExpand = class()

function CircularExpand:init(numParticles)
  self.easeMode = CircularExpand.LONG_EASE_OUT
  self.started = false
  self.circleColor = color(255,100,0,255)
  self.position = vec2(0,0)
  self.time = 0
  self.startingSize = 1
  self.endingSize = 10
  self.speedFactor = 1
  self.duration = 0.5
  self.startingRadius = 0.1 * SIZE
  self.endingRadius = 5 * SIZE
  self.particles = {}
   self.numberOfParticles = numParticles
end


function CircularExpand:explode() 
  self.started = true
  for i = 1,self.numberOfParticles do
    self.particles[i] = Circle(math.random(-self.startingRadius, self.startingRadius), math.random(-self.startingRadius, self.startingRadius), self.startingSize)
    self.particles[i].endingSize = math.random( self.endingSize * 0.5, self.endingSize )
    self.particles[i].speed = math.random( self.speedFactor * 0.5, self.speedFactor )
    self.particles[i].direction = vec2(self.particles[i].position.x, self.particles[i].position.y)
    self.particles[i].direction:normalize()
  end    
end

function CircularExpand:update()
  if not self.started then return end
  self.time = self.time + DELTA          
  local elapsed = 0
   if self.easeMode == EASE_IN then
      elapsed = easeIn(self.time/self.duration)
  elseif self.easeMode == EASE_OUT then
      elapsed = easeOut(self.time/self.duration)
  elseif self.easeMode == LONG_EASE_OUT then
      elapsed = longEaseOut(self.time/self.duration)
  else
      elapsed = veryLongEaseOut(self.time/self.duration)
  end
  for i = 1, self.numberOfParticles do
  --Update each particle
  self.particles[i].position = self.particles[i].position + self.particles[i].direction * self.particles[i].speed
  self.particles[i].circleSize = (self.particles[i].endingSize - self.startingSize) * elapsed + self.startingSize
  end      
  if elapsed >= 1 then self.started = false end
end

function CircularExpand:draw()
  if not self.started then return end
  fill(self.circleColor)    
  translate(self.position.x,self.position.y)    
  for i=1, #self.particles do 
      ellipse(self.particles[i].position.x, self.particles[i].position.y, self.particles[i].circleSize, self.particles[i].circleSize )
  end    
end

function easeIn (x)
--3/2x^2 - 1/2x^3 
return x*x*(1.5 - 0.5*x)
end

function easeOut (x)
local inv_x = 1 - x
return 1 - inv_x * inv_x * ( 1.5 - 0.5 * inv_x )
end

function longEaseOut (x)
local inv_x = 1 - x
return 1 - inv_x * inv_x * inv_x * inv_x * ( 1.5 - 0.5 * inv_x )  
end

function veryLongEaseOut (x)
local inv_x = 1 - x
return 1 - math.pow(inv_x,8) * ( 1.5 - 0.5 * inv_x )  
end
