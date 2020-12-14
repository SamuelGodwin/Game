WaitState = { mName = "wait" }
WaitState.__index = WaitState
function WaitState:Create(character, map)
    local this =
    {
        mCharacter = character,
        mMap = map,
        mEntity = character.mEntity,
        mController = character.mController,

        mFrameResetSpeed = 0.025,
        mFrameCount = 0
    }

    setmetatable(this, self)
    return this
end

function WaitState:Enter(data)
    self.mFrameCount = 0
end

function WaitState:Render(renderer) end
function WaitState:Exit() end

function WaitState:Update(dt)

    -- If we're in the wait state for a few frames, reset the frame to
    -- the starting frame.
    if self.mFrameCount ~= -1 then
        self.mFrameCount = self.mFrameCount + dt
        if self.mFrameCount >= self.mFrameResetSpeed then
            self.mFrameCount = -1
            self.mEntity:SetFrame(self.mEntity.mStartFrame)
            --self.mCharacter.mFacing = "down"
        end
    end

    if Keyboard.JustPressed(KEY_X) then
        if self.mCharacter.mFacing == "down" then
            self.mController:Change("attack", {x = 0, y = 1})
            self.mCharacter.mFacing = "attackDown"
        elseif self.mCharacter.mFacing == "up" then
            self.mController:Change("attack", {x = 0, y = -1})
            self.mCharacter.mFacing = "attackUp"
        elseif self.mCharacter.mFacing == "left" then
            self.mController:Change("attack", {x = -1, y = 0})
            self.mCharacter.mFacing = "attackLeft"
        elseif self.mCharacter.mFacing == "right" then
            self.mController:Change("attack", {x = 1, y = 0})
            self.mCharacter.mFacing = "attackRight"
        end
    elseif Keyboard.Held(KEY_LEFT) then
        self.mController:Change("move", {x = -1, y = 0})
        self.mCharacter.mFacing = "left"
    elseif Keyboard.Held(KEY_RIGHT) then
        self.mController:Change("move", {x = 1, y = 0})
        self.mCharacter.mFacing = "right"
    elseif Keyboard.Held(KEY_UP) then
        self.mController:Change("move", {x = 0, y = -1})
        self.mCharacter.mFacing = "up"
    elseif Keyboard.Held(KEY_DOWN) then
        self.mController:Change("move", {x = 0, y = 1})
        self.mCharacter.mFacing = "down"
    end

    if self.mCharacter.mFacing == "right" then
        self.mEntity:SetFrame(144)
    elseif self.mCharacter.mFacing == "left" then
        self.mEntity:SetFrame(118)
    elseif self.mCharacter.mFacing == "up" then
        self.mEntity:SetFrame(105)
    elseif self.mCharacter.mFacing == "down" then
        self.mEntity:SetFrame(131)
    elseif self.mCharacter.mFacing == "attackLeft" then
        self.mEntity:SetFrame(170)
    elseif self.mCharacter.mFacing == "attackRight" then
        self.mEntity:SetFrame(196)
    elseif self.mCharacter.mFacing == "attackUp" then
        self.mEntity:SetFrame(157)
    elseif self.mCharacter.mFacing == "attackDown" then
        self.mEntity:SetFrame(183)
    end
end


