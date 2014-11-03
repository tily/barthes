require 'term/ansicolor'

module Barthes
	class Reporter
		class Default
			include Term::ANSIColor

			def before_feature(num, name)
				puts "#{name} (##{num})"
			end

			def before_scenario(num, name, scenario, scenarios)
				puts ("\t" * scenarios.size) + "#{name} (##{num})"
			end

			def before_action(num, name, action, scenarios)
				puts ("\t" * scenarios.size) + "#{name} (##{num})"
			end

			def after_action(num, name, action, scenarios, result)
				if Barthes::Config[:quiet] == 0
					puts indent scenarios.size + 1, "request:"
					puts indent scenarios.size + 2, JSON.pretty_generate(action['request'])
					puts indent scenarios.size + 1, "response:"
					puts indent scenarios.size + 2, JSON.pretty_generate(action['response'])
				end
				expectations = result['expectations']
				expectations.each do |expectation|
					if expectation['result'] == false
						puts indent scenarios.size + 1, "failed expectation:"
						puts indent scenarios.size + 2, JSON.pretty_generate(expectation)
					end
				end
				flag = ''
				if expectations.empty? || expectations.all? {|r| r['result'] == true }
					flag = green {'success'}
				else
					flag = red {'failure'}
				end
				puts indent(scenarios.size + 1, "result: #{flag}")
			end

			def indent(num, string)
				string.split("\n").map do |line|
					("\t" * num) + line
				end.join("\n")
			end
		end
	end
end
