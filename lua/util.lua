---@diagnostic disable: unused-local, lowercase-global, undefined-global, param-type-mismatch
xero()

---@enum Difficulty
Difficulty = {}
Difficulty.DIFFICULTY_BEGINNER = 0
Difficulty.DIFFICULTY_EASY = 1
Difficulty.DIFFICULTY_MEDIUM = 2
Difficulty.DIFFICULTY_HARD = 3
Difficulty.DIFFICULTY_CHALLENGE = 4
Difficulty.DIFFICULTY_EDIT = 5

slumpage = GAMESTATE:GetCurrentSteps(0):GetDifficulty() == Difficulty.DIFFICULTY_EDIT
beat_1 = {0, 1.5, 3, 4.5, 6, 7}

---Uses `set{}` and `ease{}` same time.
---@param beat number
---@param len number
---@param ease_fn function
---@param start_percent number
---@param end_percent number
---@param mod string
---@param player integer
function setEase(beat, len, ease_fn, start_percent, end_percent, mod, player)
  set {beat, start_percent, mod, plr=player}
  ease {beat, len, ease_fn, end_percent, mod, plr=player}
end

---cool text typer
---
---you can make callback for each text typing
---@param beat number
---@param bitmaptext BitmapText
---@param type_per_beat number
---@param text string
---@param callback function
function typeText(beat, bitmaptext, type_per_beat, text, callback)
  local totalLen = string.len(text);
  for i = 1, totalLen do
    local offset = type_per_beat * i;
    local text = string.sub(text, i, i)
    func {offset+beat, function()
      bitmaptext:settext(bitmaptext:GetText()..text)
      if callback then callback() end
    end}
  end
end

function initMods()
  local dx, dy, dw, dh = DISPLAY_CENTER_X, DISPLAY_CENTER_Y+12, DISPLAY:GetWindowWidth(), DISPLAY:GetWindowHeight();

  definemod {"wx", "wy", "ww", "wh", function(x,y,w,h)
    --doing reset if the values are not correct.
    if x >= 0 and x <= DISPLAY_WIDTH-dw then x = dx end
    if y >= 0 and y <= DISPLAY_HEIGHT-dh then y = dy end
    if w <= 0 then w = dw end
    if h <= 0 then h = dh end
    DISPLAY:SetWindowX(x);
    DISPLAY:SetWindowY(y);
    DISPLAY:SetWindowWidth(w);
    DISPLAY:SetWindowHeight(h);
  end}
  alias {"tinyx", "scalex"}
  alias {"tinyy", "scaley"}
  for i = 0, 3 do
    alias {"tinyx"..i, "scalex"..i}
    alias {"tinyy"..i, "scaley"..i}
  end
  -- idk which beat player should not null
  perframe {-100, 100, function(b,p)
    for pn = 1, 8 do
      local p = P[pn];
      if p then
        PPOS[pn] = {p:GetX(), p:GetY()};
      end
    end
  end}
end

---The Receptor Goes Down, and Note Stops at their positions.
---@param beat number The Beat Mod should run at.
---@param length number The Length Mod should reset at.
---@param step number How long Loop should go.
---@param speedmod number Current Player's speed mod.
---@param plr nil|integer Player Number.
function drivendrop(beat, length, step, speedmod, plr)
  for i = beat, beat + length - step, step do
    add
    {i, step, linear, speedmod * step * 100, 'centered2', plr = plr}
    {i + step, 0, instant, -speedmod * step * 100, 'centered2', plr = plr}
  end
end

---Same as doing this.
---```lua
---aft(Aft);
---sprite(AftSprite);
---AftSprite:SetTexture(Aft:GetTexture());
---```
---@param AFT ActorFrameTexture
---@param Sprite Sprite
function setupAFT(AFT, Sprite)
  aft(AFT);
  sprite(Sprite);
  Sprite:SetTexture(AFT:GetTexture());
end

---Sets the Shader's Variable.
---@param Object RageShaderProgram
---@param uniformv string uniform version, ex) uniform1f is 1f
---@param uniformName string the variable's name.
---@param values table|number|RageTexture
function setShadVars(Object, uniformv, uniformName, values)
  if Object and values then
    uniformv = string.lower(uniformv);
    if uniformv == "1i" then Object:uniform1i(uniformName, values[1]);
      elseif uniformv == "1iv" then Object:uniform1iv(uniformName, values);
      elseif uniformv == "1f" then Object:uniform1f(uniformName, values[1]);
      elseif uniformv == "1fv" then Object:uniform1fv(uniformName, values);
      elseif uniformv == "2f" then Object:uniform2f(uniformName, values[1], values[2]);
      elseif uniformv == "2fv" then Object:uniform2fv(uniformName, values);
      elseif uniformv == "3f" then Object:uniform3f(uniformName, values[1], values[2], values[3]);
      elseif uniformv == "3fv" then Object:uniform3fv(uniformName, values);
      elseif uniformv == "4f" then Object:uniform4f(uniformName, values[1], values[2], values[3], values[4]);
      elseif uniformv == "4fv" then Object:uniform4fv(uniformName, values);
      elseif uniformv == "matrix2fv" then Object:uniformMatrix2fv(uniformName, values);
      elseif uniformv == "matrix3fv" then Object:uniformMatrix3fv(uniformName, values);
      elseif uniformv == "matrix4fv" then Object:uniformMatrix4fv(uniformName, values);
      elseif uniformv == "texture" then Object:uniformTexture(uniformName, values[1]);
    end
  end
end

proxyWallX, proxyWallY, wallRender = 0, 0, 0;
---Set Draw Function to the proxy wall, and define some mods.
---@param proxyWalls ActorFrame
function setupProxyWalls(proxyWalls)
  definemod {'prw_x', function(p) proxyWallX = p end}
  definemod {'prw_y', function(p) proxyWallY = p end}
  definemod {'prw_render', function(p) wallRender = p end}
  proxyWalls:SetDrawFunction(function()
    for pn = 1, #PP do
      local half = wallRender / 2;
      for i = -half, half do
        PP[pn]:xy(proxyWallX * i, proxyWallY * i);
        PP[pn]:Draw()
      end
    end
  end)
end