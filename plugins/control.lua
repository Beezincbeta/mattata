local control = {}
local mattata = require('mattata')

function control:init()
	local configuration = require('configuration')
	control.commands = mattata.commands(self.info.username, configuration.commandPrefix):c('reload').table
end

function control:onMessageReceive(message)
	local configuration = require('configuration')
	if message.from.id ~= configuration.owner then
		return
	end
	for p, _ in pairs(package.loaded) do
		if p:match('^plugins%.') then
				package.loaded[p] = nil
		end
	end
	package.loaded['mattata'] = nil
	package.loaded['configuration'] = nil
	if not message.text_lower:match('%-configuration') then
		for k, v in pairs(require('configuration')) do
			configuration[k] = v
		end
	end
	mattata.init(self, configuration)
	print(self.info.first_name .. ' is reloading...')
	local res = mattata.sendMessage(message.chat.id, self.info.first_name .. ' is reloading...', nil, true, false, message.message_id, nil)
	if res then
		print(self.info.first_name .. ' successfully reloaded!')
	end
end

return control