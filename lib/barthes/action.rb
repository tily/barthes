require 'barthes/cache'

module Barthes
	class Action
		def initialize(env)
			@env = env.dup
			client_class = Object.const_get(@env['client_class'])
			@client = client_class.new(env)
		end

		def action(action)
			@env.update(action['environment']) if action['environment']
			params = evaluate_params(action['params'])
			response = @client.action(params)
			p "params: #{params}"
			p "response: #{response}"
			if action['expectations']
				result = @client.compare(response, action['expectations'])
			else
				result = {result: true}
			end
			if cache_config = action['cache']
				value = @client.cache(cache_config, response)
				Barthes::Cache.set(config['key'], value)
			end
			result
		end

		def evaluate_params(params)
			new_params = {}
			params.each do |k, v|
				new_v = v.gsub(/\$\{(.+?)\}/) { @env[$1] }
				new_v = new_v.gsub(/\@\{(.+?)\}/) { Barthes::Cache.get($1) }
				new_params[k] = new_v
			end
			new_params
		end
	end
end
