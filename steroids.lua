local steroid = Item("Steroids")
steroid.pickupText = "Become stronger, as long as you keep dosing."

steroid.sprite = Sprite.load("steroids", "steroids.png", 1, 8, 15)

steroid:setTier("common")

--local boostAmount = 50
local boostMultiplier = 0.15

--local buffBaseDuration = 50 * 60

local steroidBuff = Buff.new()
local spriteAnimationSteps = 1
local spriteSize = 9
steroidBuff.sprite = Sprite.load("steroidsBuff", "steroids-buff.png", spriteAnimationSteps, math.floor(spriteSize/2),math.floor(spriteSize/2))

local steroidStepCallback = function(actor, remaining)
	-- get number of seconds expired for buff
	-- calculate percentage...
	-- change lost hp to that amount...
	if isa(actor, "PlayerInstance") then
		local maxBoost = actor:get("steroids_hp_boost") or 0
		local lostBoost = actor:get("steroids_hp_loss") or 0
		--log("maxBoost: "..maxBoost)
		--log("lostBoost: "..lostBoost)
		
		if lostBoost == maxBoost then return end -- hp loss has already come to completion
		local buffDuration = maxBoost * 60 -- loss of ~1hp per second
		local expired = buffDuration - remaining
		local newLoss = math.floor((expired / buffDuration) * maxBoost)
		--log("newLoss: "..newLoss)
		
		if newLoss == lostBoost then return end --no progression since last step
		actor:set("maxhp_base", actor:get("maxhp_base") - (newLoss - lostBoost))
		actor:set("steroids_hp_loss", newLoss)
		
		--local frame = math.floor(expired / buffDuration * buffAnimationSteps) + 1
	end
end

steroidBuff:addCallback("step", steroidStepCallback)

local steroidCallback = function(player)
	--log("max at start: "..player:get("maxhp_base"))
	--log("hp at start: "..player:get("hp"))
	local maxBoost = player:get("steroids_hp_boost") or 0
	local lostBoost = player:get("steroids_hp_loss") or 0
	
	if lostBoost > 0 then player:set("maxhp_base", player:get("maxhp_base") + lostBoost) end
	player:set("steroids_hp_loss", 0)
	local boostAmount = math.floor(player:get("maxhp_base") * boostMultiplier)
	player:set("steroids_hp_boost", maxBoost + boostAmount)
	player:set("maxhp_base", player:get("maxhp_base") + boostAmount)
	player:set("maxhp", player:get("maxhp_base"))
	
	--log("max at heal: "..player:get("maxhp_base"))
	--log("hp at heal: "..player:get("hp"))
	if player:get("lastHp") + lostBoost + boostAmount < player:get("maxhp_base") then
		player:set("hp", player:get("lastHp") + lostBoost + boostAmount)
	else
		player:set("hp", player:get("maxhp_base"))
	end
	--log("hp after heal: "..player:get("hp"))
	local numItem = player:countItem(steroid)
	player:applyBuff(steroidBuff, player:get("steroids_hp_boost") * 60)
end

steroid:addCallback("pickup", steroidCallback)

-- Set the log for the item
steroid:setLog{
	-- The tier of the item
	group = "common",
	-- A description of what the item does
	-- Usually is similar to the item's pickup text, but goes into more detail
	-- This part of the log may use colored text codes, here we use them to make the text 'by 30 points' yellow
	description = "Increases your maximum health &y&by 15 percent&!&. This will decrease over time until you pick up &y&steroids&!& again, returning all previous steroid gains.",
	-- The main part of the item log
	-- Usually includes some lore about the item
	-- Will automatically wrap around when it reaches the edge of the text area
	story = "Developed by a renegade paramilitary organisation, these steroids are highly illegal.",
	-- The item's destination, shown on the top right of the log
	destination = "[REDACTED]",
	-- The package estimated arrival date
	date = "4/24/2096"
}
