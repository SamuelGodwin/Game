Entity = {}
Entity.__index = Entity
function Entity:Create(def)
    local this =
    {
        mSprite = Sprite.Create(),
        mTexture = Texture.Find(def.texture),
        mHeight = def.height,
        mWidth = def.width,
        mTileX = def.tileX,
        mTileY = def.tileY,
        mLayer = def.layer,
        mStartFrame = def.startFrame,
    }

    this.mSprite:SetTexture(this.mTexture)
    this.mUVs = GenerateUVs(this.mWidth, this.mHeight, this.mTexture)
    setmetatable(this, self)
    this:SetFrame(this.mStartFrame)
    return this
end

function Entity:SetFrame(frame)
    self.mSprite:SetUVs(unpack(self.mUVs[frame]))
end