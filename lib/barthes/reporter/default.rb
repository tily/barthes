require 'term/ansicolor'

module Barthes
	class Reporter
		class Default
			include Term::ANSIColor

			def initialize(opts={})
				@opts = opts
			end

			def before_feature(num, name)
				puts "#{name} (##{num})"
			end

			def before_scenario(num, name, scenario, scenarios)
				puts ("\t" * scenarios.size) + "#{name} (##{num})"
			end

			def before_action(num, name, action, scenarios)
				puts ("\t" * scenarios.size) + "#{name} (##{num})"
			end

			def after_action(num, name, action, scenarios)
				if Barthes::Config[:quiet] == 0 && Barthes::Config[:dryrun] == 0
					puts indent scenarios.size + 1, "request:"
					puts indent scenarios.size + 2, JSON.pretty_generate(action['request'])
					puts indent scenarios.size + 1, "response:"
					puts indent scenarios.size + 2, JSON.pretty_generate(action['response'])
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
				elsif expectations.empty? || expectations.all? {|r| r['result'] == true }
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
