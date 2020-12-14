
Map = {}
Map.__index = Map
function Map:Create(mapDef)
    local layer = mapDef.layers[1]
    local this =
    {

        mX = 0,
        mY = 0,
        mMapDef = mapDef,
        mTextureAtlas = Texture.Find(mapDef.tilesets[1].image),

        mTileSprite = Sprite.Create(),
        mLayer = layer,
        mWidth = layer.width,
        mHeight = layer.height,

        mTiles = layer.data,
        mTileWidth = mapDef.tilesets[1].tilewidth,
        mTileHeight = mapDef.tilesets[1].tileheight,
        mTriggers = {}

    }
    this.mTileSprite:SetTexture(this.mTextureAtlas)

    -- Top left corner of the map
    this.mX = -System.ScreenWidth() / 2 + this.mTileWidth / 2
    this.mY = System.ScreenHeight() / 2 - this.mTileHeight / 2

    this.mCamX = 0
    this.mCamY = 0

    this.mWidthPixel = this.mWidth * this.mTileWidth
    this.mHeightPixel = this.mHeight * this.mTileHeight
    this.mUVs = GenerateUVs(mapDef.tilesets[1].tilewidth,
                            mapDef.tilesets[1].tileheight,
                            this.mTextureAtlas)

    -- Assign blocking tile id
    for _, v in ipairs(mapDef.tilesets) do
        if v.name == "collision_graphic" then
            this.mBlockingTile = v.firstgid
        end
    end
    assert(this.mBlockingTile)
    print('blocking tile is', this.mBlockingTile)

    setmetatable(this, self)

    return this
end

function Map:GetTile(x, y, layer)
    local layer = layer or 1
    local tiles = self.mMapDef.layers[layer].data

    return tiles[self:CoordToIndex(x, y)]
end

function Map:GetTrigger(layer, x, y)
    -- Get the triggers on the same layer as the entity
    local triggers = self.mTriggers[layer]

    if not triggers then
        return
    end

    local index = self:CoordToIndex(x, y)
    return triggers[index]
end

function Map:CoordToIndex(x, y)
    x = x + 1 -- change from  1 -> rowsize
              -- to           0 -> rowsize - 1
    return x + y * self.mWidth
end

function Map:IsBlocked(layer, tileX, tileY)
    -- Collision layer should always be 2 above the official layer
    local tile = self:GetTile(tileX, tileY, layer + 2)
    --print(tileX, tileY, layer, tile, tile == self.mBlockingTile)
    return tile == self.mBlockingTile
end

function Map:GetTileFoot(x, y)
    return  self.mX + (x * self.mTileWidth),
            self.mY - (y * self.mTileHeight) - self.mTileHeight / 2
end

function Map:GotoTile(x, y)
    self:Goto((x * self.mTileWidth) + self.mTileWidth/2,
              (y * self.mTileHeight) + self.mTileHeight/2)
end

function Map:Goto(x, y)
    self.mCamX = x - System.ScreenWidth()/2
    self.mCamY = -y + System.ScreenHeight()/2
end

function Map:PointToTile(x, y)

    -- Tiles are rendered from the center so we adjust for this.
    x = x + self.mTileWidth / 2
    y = y - self.mTileHeight / 2

    -- Clamp the point to the bounds of the map
    x = math.max(self.mX, x)
    y = math.min(self.mY, y)
    x = math.min(self.mX + self.mWidthPixel - 1, x)
    y = math.max(self.mY- self.mHeightPixel + 1, y)


    -- Map from the bounded point to a tile
    local tileX = math.floor((x - self.mX) / self.mTileWidth)
    local tileY = math.floor((self.mY - y) / self.mTileHeight)

    return tileX, tileY
end

function Map:LayerCount()
    -- Number of layers should be a factor of 3
    assert(#self.mMapDef.layers % 3 == 0)
    return #self.mMapDef.layers / 3
end


function Map:Render(renderer)
    self:RenderLayer(renderer, 1)
end


function Map:RenderLayer(renderer, layer)

    -- Our layers are made of 3 sections
    -- We want the index to point to the tile layer of a give section
    local layerIndex = (layer * 3) - 2

    local tileLeft, tileBottom =
        self:PointToTile(self.mCamX - System.ScreenWidth() / 2,
                         self.mCamY - System.ScreenHeight() / 2)

    local tileRight, tileTop =
        self:PointToTile(self.mCamX + System.ScreenWidth() / 2,
                         self.mCamY + System.ScreenHeight() / 2)

    for j = tileTop, tileBottom do
        for i = tileLeft, tileRight do

            local tile = self:GetTile(i, j, layerIndex)
            local uvs = {}


            self.mTileSprite:SetPosition(self.mX + i * self.mTileWidth,
                                         self.mY - j * self.mTileHeight)

            -- There can be empty tiles in the first layer too!
            if tile > 0 then
                uvs = self.mUVs[tile]
                self.mTileSprite:SetUVs(unpack(uvs))
                renderer:DrawSprite(self.mTileSprite)
            end

            -- The second section of layer is always the decoration.
            tile = self:GetTile(i, j, layerIndex + 1)

            -- If the decoration tile exists
            if tile > 0 then
                uvs = self.mUVs[tile]
                self.mTileSprite:SetUVs(unpack(uvs))
                renderer:DrawSprite(self.mTileSprite)
            end

        end
    end
end