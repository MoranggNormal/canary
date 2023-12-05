local action = Action()

local function doPlayerAddExperience(cid, exp)
	local player = Player(cid)
	if player then
		player:addExperience(exp, true)
	end
	return true
end

function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local tile = Tile(toPosition)

	-- local corpse = tile:getTopDownItem():getType()

	-- if corpse:isCorpse() then
	-- 	MonsterCorpse(corpse:getId()):name()
	-- 	print(MonsterCorpse(corpse:getId()):isAttackable())
	-- end

	if not tile or not tile:getTopDownItem() or not tile:getTopDownItem():getType():isCorpse() then
		return false
	end

	local targetCorpse = tile:getTopDownItem()

	local owner = targetCorpse:getAttribute(ITEM_ATTRIBUTE_CORPSEOWNER)

	if owner ~= 0 and owner ~= player:getId() then
		player:sendCancelMessage("Sorry, not possible. You are not the owner.")
		return true
	end

	-- local ballKey = getPokeballKey(item:getId())
	local playerPos = getPlayerPosition(player)
	local d = getDistanceBetween(playerPos, toPosition)
	local delay = d * 80
	local delayMessage = delay + 2800
	local monsterType = MonsterCorpse(targetCorpse:getType():getId())

	player:sendTextMessage(MESSAGE_INFO_DESCR, monsterType:name())

	if not monsterType then
		player:sendCancelMessage("Sorry, not possible. This problem was reported.")
		return true
	end

	-- local chance = monsterType:catchChance() * balls[ballKey].chanceMultiplier
	local chance = monsterType:catchChance() * pokeBalls.pokeball.chanceMultiplier

	if chance == 0 then
		if playerPos ~= nil then
			playerPos:sendMagicEffect(CONST_ME_POFF)
		end
		player:sendCancelMessage("Sorry, it is impossible to catch this monster.")
		return true
	end


	doSendDistanceShoot(playerPos, toPosition, 60)

	item:remove(1)
	targetCorpse:remove()

	if math.random(1, 300) <= chance then -- caught
		-- check how many pokeballs the player has
		if player:getSlotItem(CONST_SLOT_BACKPACK) and player:getSlotItem(CONST_SLOT_BACKPACK):getEmptySlots() >= 1 and player:getFreeCapacity() >= 1 then -- add to backpack
			addEvent(doAddPokeball, delayMessage, player:getId(), monsterType:name(), 10, 10, 44183, false, delayMessage)
		else -- send to cp
			local addPokeball = doAddPokeball(player:getId(), monsterType:name(), 10, 10, 44183, true, delayMessage + 4000)
			if not addPokeball then
				print("ERROR! Player " .. player:getName() .. " lost pokemon " .. name .. "! addPokeball false")
			end
			addEvent(doPlayerSendTextMessage, delayMessage + 2000, player:getId(), MESSAGE_EVENT_ADVANCE, "Since you are at maximum capacity, your ball was sent to CP.")
		end

		local playerLevel = player:getLevel()
		-- local maxExp = getNeededExp(playerLevel + 2) - getNeededExp(playerLevel)
		-- local maxExpShiny = getNeededExp(playerLevel + 5) - getNeededExp(playerLevel)
		local maxExp = playerLevel
		local maxExpShiny = playerLevel

		-- local givenExp = monsterType:getExperience() * configManager.getNumber(configKeys.RATE_EXPERIENCE)
		local givenExp = 100 * configManager.getNumber(configKeys.RATE_EXPERIENCE)
		-- if msgcontains(name, 'Shiny') and player:getStorageValue(storageCatch) == -1 then
		-- 	givenExp = givenExp * multiplierExpFirstShiny
		-- 	if givenExp > maxExpShiny then
		-- 		givenExp = maxExpShiny
		-- 	end
		-- 	addEvent(doPlayerSendTextMessage, delayMessage + 1000, player:getId(), MESSAGE_EVENT_ADVANCE, "You got a bonus exp for your first catch of " .. name .. "!")
		-- elseif msgcontains(name, 'Shiny') and player:getStorageValue(storageCatch) > 0 then
		-- 	givenExp = givenExp * multiplierExpShiny
		-- 	if givenExp > maxExpShiny then
		-- 		givenExp = maxExpShiny
		-- 	end
		-- 	addEvent(doPlayerSendTextMessage, delayMessage + 1000, player:getId(), MESSAGE_EVENT_ADVANCE, "You got a bonus exp for catching a shiny!")
		-- elseif not msgcontains(name, 'Shiny') and player:getStorageValue(storageCatch) == -1 then
		-- 	givenExp = givenExp * multiplierExpFirstNormal
		-- 	if givenExp > maxExp then
		-- 		givenExp = maxExp
		-- 	end
		-- 	addEvent(doPlayerSendTextMessage, delayMessage + 1000, player:getId(), MESSAGE_EVENT_ADVANCE, "You got a bonus exp for your first catch of " .. name .. "!")
		-- else
		givenExp = givenExp * 10
		if givenExp > maxExp then
			givenExp = maxExp
		end
		-- end

		-- if player:getStorageValue(storageCatch) == -1 then
		-- 	player:setStorageValue(storageCatch, 1)
		-- else
		-- 	player:setStorageValue(storageCatch, player:getStorageValue(storageCatch) + 1)
		-- end

		addEvent(doPlayerAddExperience, delayMessage, player:getId(), givenExp)
		-- addEvent(doSendMagicEffect, delay, toPosition, balls[ballKey].effectSucceed)
		-- addEvent(doSendMagicEffect, delay, toPosition, CONST_ME_BIGPLANTS)
		-- addEvent(doSendMagicEffect, delay, toPosition, CONST_ME_POKEBALL_SUCCESS)
		-- player:getPosition():sendMagicEffect(262)
		player:getPosition():sendMagicEffect(264)

		addEvent(doPlayerSendTextMessage, delayMessage, player:getId(), MESSAGE_EVENT_ADVANCE, "Congratulations! You have caught a " .. monsterType:name() .. "!")
		-- addEvent(doPlayerSendEffect, delayMessage, player:getId(), 297)
	else -- missed
		-- addEvent(doSendMagicEffect, delay, toPosition, balls[ballKey].effectFail)
		addEvent(doSendMagicEffect, delay, toPosition, CONST_ME_POFF)
		addEvent(doPlayerSendEffect, delayMessage, player:getId(), 286)
		return true
	end

	return true
end

action:id(44184)
action:register()
