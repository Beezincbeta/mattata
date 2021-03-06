local currency = {}
local HTTPS = require('ssl.https')
local mattata = require('mattata')

function currency:init()
	local configuration = require('configuration')
	currency.arguments = 'currency <amount> <from> TO <to>'
	currency.commands = mattata.commands(self.info.username, configuration.commandPrefix):c('currency').table
	currency.help = configuration.commandPrefix .. 'currency <amount> <from> TO <to> - Converts exchange rates for various currencies. Source: Google Finance.'
end

function currency:onMessageReceive(message)
	local configuration = require('configuration')
	local input = message.text:upper()
	if not input:match('%a%a%a TO %a%a%a') then
		mattata.sendMessage(message.chat.id, currency.help, nil, true, false, message.message_id, nil)
		return
	end
	local from = input:match('(%a%a%a) TO')
	local to = input:match('TO (%a%a%a)')
	local amount = mattata.getWord(input, 2)
	amount = tonumber(amount) or 1
	local result = 1
	local api = configuration.apis.currency
	if from ~= to then
		api = api .. '?from=' .. from .. '&to=' .. to .. '&a=' .. amount
		local str, res = HTTPS.request(api)
		if res ~= 200 then
			mattata.sendMessage(message.chat.id, configuration.errors.connection, nil, true, false, message.message_id, nil)
			return
		end
		str = str:match('<span class=bld>(.*) %u+</span>')
		if not str then
			mattata.sendMessage(message.chat.id, configuration.errors.results, nil, true, false, message.message_id, nil)
			return
		end
		result = string.format('%.2f', str)
	end
	local output = amount .. ' ' .. from .. ' = ' .. result .. ' ' .. to .. '\n\n'
	output = output .. os.date('!%F %T UTC') .. '\nSource: Google Finance'
	output = '\n' .. output .. '\n'
	mattata.sendMessage(message.chat.id, output, nil, true, false, message.message_id, nil)
end

return currency