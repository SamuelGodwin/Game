LoadLibrary("Renderer")
LoadLibrary("Sprite")
LoadLibrary("System")
LoadLibrary("Texture")
LoadLibrary("Vector")
LoadLibrary("Asset")
LoadLibrary("Keyboard")


Asset.Run("Animation.lua")
Asset.Run("Map.lua")
Asset.Run("Util.lua")
Asset.Run("Entity.lua")
Asset.Run("StateMachine.lua")
Asset.Run("MoveState.lua")
Asset.Run("WaitState.lua")
Asset.Run("AttackState.lua")
Asset.Run("Tween.lua")
Asset.Run("Actions.lua")
Asset.Run("Trigger.lua")
Asset.Run("small_room.lua")


local gMap = Map:Create(CreateMap1())
gRenderer = Renderer:Create()

gMap:GotoTile(5, 5)

local heroDef =
{
    texture = "hero.png",
    width = 32,
    height = 32,
    startFrame = 132,
    tileX = 11,
    tileY = 3,
    layer = 1
}

gHero =
{
    mAnimUp = {105, 106, 107, 108, 109, 110, 111, 112, 113},
    mAnimLeft = {118, 119, 120, 121, 122, 123, 124, 125, 126},
    mAnimDown = {131, 132, 133, 134, 135, 136, 137, 138, 139},
    mAnimRight = {144, 145, 146, 147, 148, 149, 150, 151, 152},
    mAnimAttackUp = {157, 158, 159, 160, 161, 162},
    mAnimAttackLeft = {170, 171, 172, 173, 174, 175},
    mAnimAttackDown = {183, 184, 185, 186, 187, 188},
    mAnimAttackRight = {196, 197, 198, 199, 200, 201},
    mFacing = "down",
    mEntity = Entity:Create(heroDef),
    Init =
    function(self)
        self.mController = StateMachine:Create
        {
            ['wait'] = function() return self.mWaitState end,
            ['move'] = function() return self.mMoveState end,
            ['attack'] = function() return self.mAttackState end,
        }
        self.mWaitState = WaitState:Create(self, gMap)
        self.mMoveState = MoveState:Create(self, gMap)
        self.mAttackState = AttackState:Create(self, gMap)
        self.mController:Change("wait")
    end
}
gHero:Init()

gUpDoorTeleport = Actions.Teleport(gMap, 11, 3)
gDownDoorTeleport = Actions.Teleport(gMap, 10, 11)
gUpDoorTeleport(nil, gHero.mEntity)

gTriggerTop = Trigger:Create
{
    OnEnter = gDownDoorTeleport
}

gTriggerBot = Trigger:Create
{
    OnEnter = gUpDoorTeleport,
}

gTriggerStart = Trigger:Create
{
    OnExit = function() gMessage = "OnExit: Left the start position" end
}

gTriggerPot = Trigger:Create
{
    OnUse = function() gMessage = "OnUse: The pot is full of snakes!" end,
}

gMap.mTriggers =
{
    -- Layer 1
    {
        [gMap:CoordToIndex(10, 12)] = gTriggerBot,
        [gMap:CoordToIndex(11, 2)] = gTriggerTop,
        [gMap:CoordToIndex(11, 3)] = gTriggerStart,
        [gMap:CoordToIndex(10, 3)] = gTriggerPot,
    }
}

function GetFacedTileCoords(character)

    -- Change the facing information into a tile offset
    local xInc = 0
    local yInc = 0

    if character.mFacing == "left" then
        xInc = -1
    elseif character.mFacing == "right" then
        xInc = 1
    elseif character.mFacing == "up" then
        yInc = -1
    elseif character.mFacing == "down" then
        yInc = 1
    end

    local x = character.mEntity.mTileX + xInc
    local y = character.mEntity.mTileY + yInc

    return x, y
end


gMessage = "Hello There"

function update()

    local dt = GetDeltaTime()

    local playerPos = gHero.mEntity.mSprite:GetPosition()
    gMap.mCamX = math.floor(playerPos:X())
    gMap.mCamY = math.floor(playerPos:Y())

    gRenderer:Translate(-gMap.mCamX, -gMap.mCamY)

    local layerCount = gMap:LayerCount()

    for i = 1, layerCount do
        gMap:RenderLayer(gRenderer, i)
        if i == gHero.mEntity.mLayer then
            gRenderer:DrawSprite(gHero.mEntity.mSprite)
        end
    end

    gHero.mController:Update(dt)

    if Keyboard.JustPressed(KEY_SPACE) then
        -- which way is the player facing?
        local x, y = GetFacedTileCoords(gHero)
        local trigger = gMap:GetTrigger(gHero.mEntity.mLayer, x, y)
        if trigger then
            trigger:OnUse(gHero)
        end
    end

    gRenderer:DrawRect2d(
        gMap.mCamX-System.ScreenWidth()/2,
        gMap.mCamY+System.ScreenHeight()/2,
        gMap.mCamX+ System.ScreenWidth()/2,
        gMap.mCamY+System.ScreenHeight()/2 - 60,
        Vector.Create(0, 0, 0, 1)
    )

    local y =  gMap.mCamY+System.ScreenHeight()/2 - 30
    gRenderer:AlignText("center", "center")
    gRenderer:DrawText2d(gMap.mCamX, y, gMessage, Vector.Create(1,1,1,1))

    gRenderer:AlignTextX("left")
    gRenderer:DrawText2d(-30, 150, "Try using the pot (USE = space key)", Vector.Create(1,1,1,1), 175)

end