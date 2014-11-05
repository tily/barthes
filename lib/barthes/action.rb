require 'barthes/cache'
require 'chronic'

module Barthes
	class Action
		def initialize(env)
			@env = env.dup
			client_class = Object.const_get(@env['client_class'])
			@client = client_class.new(env)
		end

		def indent(size, string)
			string.split("\n").map {|line| "\t" * size + "#{line}\n" }
		end

		def action(action)
			begin
				@env.update(action['env']) if action['env']
				params = evaluate_params(action['params'])

				if action['expectations']
					if action['max_loop']
						action['max_loop'].to_i.times do
							sleep action['sleep'].to_i/1000 if action['sleep']	

							response = @client.action(params)
							action['expectations'].each do |expectation|
								result = @client.compare(response, evaluate_params(expectation))
								expectation.update(result)
							end
							if action['expectations'].all? {|e| e['result'] == true }
								break
							end
						end
					end
				end

				sleep action['sleep'].to_i/1000 if action['sleep']	

				action['request'] = params
				action['response'] = response = @client.action(params)

				if action['expectations'] && !action['expectations'].empty?
					action['expectations'].each do |expectation|
						result = @client.compare(response, evaluate_params(expectation))
						expectation.update(result)
					end
					if !action['expectations'].all? {|e| e['result'] == true }
						action['status'] = 'failure'
					else
						action['status'] = 'success'
					end
				else
					action['status'] = 'success'
				end

				if cache_config = action['cache']
					value = @client.extract(cache_config, response)
					action['cache']['value'] = value
					Barthes::Cache[cache_config['key']] = value
				end
			rescue StandardError => e
				action['status'] = 'error'
				action['error'] = {
					'class' => e.class,
					'message' => e.message,
					'backtrace' => e.backtrace
				}
			end
			action
		end

		def evaluate_params(params)
			new_params = {}
			params.each do |k, v|
				if v.class == String
					new_v = v.gsub(/\$\{time:(.+?):(.+?)\}/) { Chronic.parse($1).strftime($2) }
					new_v = new_v.gsub(/\$\{(.+?)\}/) { p $1; @env[$1] }
					new_v = new_v.gsub(/\@\{(.+?)\}/) { Barthes::Cache[$1] }
				else
					new_v = v
				end
				new_params[k] = new_v
			end
			new_params
		end
	end
end
