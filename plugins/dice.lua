local dice = {}
local mattata = require('mattata')

function dice:init(configuration)
	dice.arguments = 'dice <number of dice> <range of numbers>'
	dice.commands = mattata.commands(self.info.username, configuration.commandPrefix):c('dice').table
	dice.help = configuration.commandPrefix .. 'dice <number of dice to roll> <range of numbers on the dice> - Rolls a die a given amount of times, with a given range.'
end

function dice:onMessageReceive(message, configuration)
	local input = mattata.input(message.text)
	if not input then
		mattata.sendMessage(message.chat.id, dice.help, nil, true, false, message.message_id, nil)
		return
	end
	local count, range
	if input:match('^[%d]+ [%d]+$') then
		count, range = input:match('([%d]+) ([%d]+)')
	elseif input:match('^d?[%d]+$') then
		count = 1
		range = input:match('^d?([%d]+)$')
	end
	count = tonumber(count)
	range = tonumber(range)
	if range < configuration.dice.minimumRange then
		mattata.sendMessage(message.chat.id, 'The minimum range is ' .. configuration.dice.minimumRange .. '.', nil, true, false, message.message_id, nil)
		return
	end
	if range > configuration.dice.maximumRange or count > configuration.dice.maximumCount then
		if configuration.dice.maximumRange == configuration.dice.maximumCount then
			mattata.sendMessage(message.chat.id, 'The maximum range and count are both ' .. configuration.dice.maximumRange .. '.', nil, true, false, message.message_id, nil)
			return
		else
			mattata.sendMessage(message.chat.id, 'The maximum range is ' .. configuration.dice.maximumRange .. ', and the maximum count is ' .. configuration.dice.maximumCount .. '.', nil, true, false, message.message_id, nil)
			return
		end
	end
	local output = '*' .. count .. '* rolls with a range of *' .. range .. '*\n'
	for _ = 1, count do
		output = output .. math.random(range) .. '\t'
	end
	mattata.sendMessage(message.chat.id, output, 'Markdown', true, false, message.message_id, nil)
end

return dice