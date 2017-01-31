local _WIDTH_ = 640
local _HEIGHT_ = 480
local playerMoveSpeed = 400
local pongMoveSpeed = 300
local showFps = false
local score = {0,0}

player = {
    x = 0,
    y = 0,
    h = 100, -- height
    w = 10, -- width
    m = "idle" -- movement : up down idle
}

function player:move(dir, dt)
    if dir == "up" and self.y > 0 then
        self.y = self.y - (playerMoveSpeed*dt)
        if self.y < 0 then self.y = 0 end
        self.m = "up"
    elseif dir == "down" and self.y+self.h < _HEIGHT_ then
        self.y = self.y + (playerMoveSpeed*dt)
        if self.y+self.h > _HEIGHT_ then self.y = _HEIGHT_-self.h end
        self.m = "down"
    else
        self.m = "idle"
    end
end

function player:center()
    self.y = (_HEIGHT_-self.h)/2
end

function player:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

pong = {
    x = 0,
    y = 0,
    r = 8, -- radius
    a = 0, -- angle
    xd = 0, -- x dir
    yd = 0 -- y dir
}

function pong:move(dt,player1,player2)
    local nextYpos = self.y+(self.yd*pongMoveSpeed*dt)
    local nextXpos = self.x+(self.xd*pongMoveSpeed*dt)

    -- check if top or bottom collision
    if self.yd < 0 and nextYpos < self.r then
        self.yd = math.abs(self.yd)
        self.y = self.r+(self.r-nextYpos) -- y = border top (radius) + collision offset
    elseif self.yd > 0 and nextYpos > _HEIGHT_-self.r then
        self.yd = 0 - math.abs(self.yd)
        self.y = _HEIGHT_-self.r-(_HEIGHT_-self.r-nextYpos)
    else
        self.y = nextYpos
    end

    -- check if left or right collision
    if self.xd < 0 and nextXpos < self.r+player1.w then
        if self.y > player1.y and self.y < player1.y+player1.h then
            self:changeAngle(player1.m)
            self.xd = math.abs(self.xd)
        else
            goal(2)
        end
    elseif self.xd > 0 and nextXpos > _WIDTH_-self.r-player2.w then
        if self.y > player2.y and self.y < player2.y+player2.h then
            self:changeAngle(player2.m)
            self.xd = 0 - math.abs(self.xd)
        else
            goal(1)
        end
    else
        self.x = nextXpos
    end
end

function pong:changeAngle(dir)


    if (dir == "up" and self.yd <= 0) or (dir == "down" and self.yd >= 0) then
        self.a = self.a+math.rad(10)
    elseif (dir == "up" and self.yd >= 0) or (dir == "down" and self.yd <= 0) then
        self.a = self.a-math.rad(10)
    end


    if self.a > math.rad(60) then
        self.a = math.rad(60)
    elseif self.a < math.rad(-60) then
        self.a = math.rad(-60)
    end

    self.xd = math.cos(self.a)
    if self.yd > 0 then
        print("up")
        self.yd = math.sin(math.abs(self.a))
    else
        print("down")
        self.yd = 0 - math.sin(math.abs(self.a))
    end
    print(math.deg(self.a))
end

function pong:center()
    self.x = _WIDTH_/2
    self.y = _HEIGHT_/2
    self.a = math.random()
    self.xd = math.cos(self.a)
    self.yd = math.sin(self.a)
end

function goal(pid)
    score[pid] = score[pid]+1
    
    pong:center()
    player1:center()
    player2:center()
end

function love.load()
    love.window.setTitle("pong2k17")
    tinyfont = love.graphics.newFont(14)
    bigfont = love.graphics.newFont(40)

    player1 = player:new()
    player1:center()

    player2 = player:new{x=_WIDTH_-10}
    player2:center()

    pong:center()

    love.window.setMode(_WIDTH_, _HEIGHT_, { vsync = false }) -- ! vsync makes moving the window super laggy
    canvas = love.graphics.newCanvas(10, _HEIGHT_)
 
    love.graphics.setCanvas(canvas)
        love.graphics.clear()
        love.graphics.setBlendMode("alpha")

        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.rectangle('fill', 0, 0, 10, _HEIGHT_)

        love.graphics.setColor(255, 255, 255, 255)
        local ntiles = math.ceil(_HEIGHT_/40)
        local tileHeight = math.ceil(10/ntiles)+40 -- gap between tiles / #tiles that fit + tile height
        for i=0, ntiles-1 do
            love.graphics.rectangle('fill', 0, i*tileHeight, 10, 30)
        end
    love.graphics.setCanvas()
end

function love.draw()
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(canvas, (_WIDTH_/2)-10 , 0) -- centered

    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(255, 255, 255, 255)
    if showFps then
        love.graphics.setFont(tinyfont)
        love.graphics.print(tostring(love.timer.getFPS()).." fps", 10, 10)
    end
    love.graphics.setFont(bigfont)
    love.graphics.print(score[1],(_WIDTH_/2)-80, 10)
    love.graphics.print(score[2],(_WIDTH_/2)+40, 10)

    love.graphics.rectangle('fill', player1.x, player1.y, player1.w, player1.h)
    love.graphics.rectangle('fill', player2.x, player2.y, player2.w, player2.h)
    love.graphics.circle('fill', pong.x, pong.y, pong.r)
end

function love.update(dt)
    local p1up = love.keyboard.isDown("z")
    local p1down = love.keyboard.isDown("s")
    local p2up = love.keyboard.isDown("up")
    local p2down = love.keyboard.isDown("down")
    local d

    if p1up and not p1down then
        d = "up"
    elseif p1down and not p1up then
        d = "down"
    else
        d = "idle"
    end
    player1:move(d,dt)

    if p2up and not p2down then
        d = "up"
    elseif p2down and not p2up then
        d = "down"
    else
        d = "idle"
    end
    player2:move(d,dt)

    pong:move(dt,player1,player2)

end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f1" then
        showFps = not showFps -- toggle
    elseif key == "f2" and player1 and player2 then
        player1:center()
        player2:center()
        pong:center()
        score = {0,0}
    end
end
