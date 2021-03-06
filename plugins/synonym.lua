local synonym = {}
local HTTPS = require('ssl.https')
local URL = require('socket.url')
local JSON = require('dkjson')
local mattata = require('mattata')

function synonym:init(configuration)
	synonym.arguments = 'synonym <word>'
	synonym.commands = mattata.commands(self.info.username, configuration.commandPrefix):c('synonym').table
	synonym.help = configuration.commandPrefix .. 'synonym <word> - Sends a synonym of the given word.'
end

function synonym:onMessageReceive(message, configuration)
	local input = mattata.input(message.text)
	if not input then
		mattata.sendMessage(message.chat.id, synonym.help, nil, true, false, message.message_id, nil)
		return
	end
	local url = configuration.apis.synonym .. configuration.keys.synonym .. '&lang=' .. configuration.language .. '-' .. configuration.language .. '&text=' .. URL.escape(input)
	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		mattata.sendMessage(message.chat.id, configuration.errors.connection, nil, true, false, message.message_id, nil)
		return
	end
	local jdat = JSON.decode(jstr)
	if jstr == '{"head":{},"def":[]}' then
		mattata.sendMessage(message.chat.id, configuration.errors.results, nil, true, false, message.message_id, nil)
		return
	else
		mattata.sendMessage(message.chat.id, 'You could use the word *' .. jdat.def[1].tr[1].text .. '* instead.', 'Markdown', true, false, message.message_id, nil)
		return
	end
end

return synonym