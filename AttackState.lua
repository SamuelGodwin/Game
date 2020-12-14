AttackState = { mName = "attack" }
AttackState.__index = AttackState
function AttackState:Create(character, map)
    local this =
    {
        mCharacter = character,
        mMap = map,
        mTileWidth = map.mTileWidth,
        mEntity = character.mEntity,
        mController = character.mController,
        mMoveX = 0,
        mMoveY = 0,
        mTween = Tween:Create(0, 0, 1),
        mMoveSpeed = 0.3,

    }

    this.mAnim = Animation:Create({ this.mEntity.mStartFrame }, false, 0.03)   

    setmetatable(this, self)
    return this
end

function AttackState:Enter(data)

    local frames = nil

    if data.x == 1 then
        frames = self.mCharacter.mAnimAttackRight
        self.mCharacter.mFacing = "attackRight"
    elseif data.x == -1 then
        frames = self.mCharacter.mAnimAttackLeft
        self.mCharacter.mFacing = "attackLeft"
    elseif data.y == -1 then
        frames = self.mCharacter.mAnimAttackUp
        self.mCharacter.mFacing = "attackUp"
    elseif data.y == 1 then
        frames = self.mCharacter.mAnimAttackDown
        self.mCharacter.mFacing = "attackDown"
    end

    self.mAnim:SetFrames(frames)
    self.mTween = Tween:Create(0, 0, self.mMoveSpeed)

end

function AttackState:Exit()

    if self.mCharacter.mFacing == "attackRight" then
        self.mCharacter.mFacing = "right"
    elseif self.mCharacter.mFacing == "attackLeft" then
        self.mCharacter.mFacing = "left"
    elseif self.mCharacter.mFacing == "attackUp" then
        self.mCharacter.mFacing = "up"
    elseif self.mCharacter.mFacing == "attackDown" then
        self.mCharacter.mFacing = "down"
    end

    self.mAnim.mIndex = 1

end

function AttackState:Render(renderer) end

function AttackState:Update(dt)

    self.mAnim:Update(dt)
    self.mEntity:SetFrame(self.mAnim:Frame())

    self.mTween:Update(dt)

    if self.mTween:IsFinished() then

        self.mAnim.mIndex = 1
        self.mController:Change("wait")
    
    end
end

