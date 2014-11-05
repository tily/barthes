require 'term/ansicolor'

module Barthes
	class Reporter
		class Default
			include Term::ANSIColor

			def initialize(opts={})
				@opts = opts
			end

			def before_feature(name)
				puts name
			end

			def before_scenario(name, scenario, scenarios)
				puts ("\t" * scenarios.size) + name
			end

			def before_action(name, action, scenarios)
				puts ("\t" * scenarios.size) + "##{action['number']} #{name}"
			end

			def after_action(name, action, scenarios)
				if Barthes::Config[:quiet] == 0 && Barthes::Config[:dryrun] == 0
					puts indent scenarios.size + 1, "request:"
					puts indent scenarios.size + 2, JSON.pretty_generate(action['request'])
					if %w(success failure).include?(action['status'])
						puts indent scenarios.size + 1, "response:"
						puts indent scenarios.size + 2, JSON.pretty_generate(action['response'])
					elsif action['status'] == 'error'
						puts indent scenarios.size + 1, "error:"
						puts indent scenarios.size + 2, "class: #{action['error']['class']}"
						puts indent scenarios.size + 2, "message: #{action['error']['message']}"
						puts indent scenarios.size + 2, "backtrace:"
						puts indent scenarios.size + 3, action['error']['backtrace'].join("\n")
					end
				end
				expectations = action['expectations'] || []
				expectations.each do |expectation|
					if expectation['result'] == false
						puts indent scenarios.size + 1, "failed expectation:"
						puts indent scenarios.size + 2, JSON.pretty_generate(expectation)
					end
				end
				flag = ''
				if Barthes::Config[:dryrun] > 0
					flag = 'skipped'
				elsif action['status'] == 'success'
					flag = green { action['status'] }
				else
					flag = red { action['status'] }
				end
				puts indent(scenarios.size + 1, "result: #{flag}")
			end

			def indent(num, string)
				string.split("\n").map do |line|
					("\t" * num) + line
				end.join("\n")
			end

			def after_run(features)
				@count = Hash.new(0)
				walk_json(features)
				puts '-' * 80
				puts [
					"all: #{@count['all'].to_s }",
					"success: #{@count['success'] > 0 ? green { @count['success'].to_s } : @count['success'].to_s }",
					"failure: #{@count['failure'] > 0 ? red { @count['failure'].to_s }   : @count['failure'].to_s }",
					"error: #{@count['error'] > 0 ? red { @count['error'].to_s } : @count['error'].to_s }",
					"skipped: #{@count['skipped'].to_s }"
				].join(", ")
			end

			def walk_json(obj)
				case obj.first
				when 'feature', 'scenario'
					walk_json(obj.last)
				when 'action'
					@count['all'] += 1
					@count[obj.last['status']] += 1
				else
					obj.each {|obj2| walk_json(obj2) }
				end
			end
		end
	end
end
