
module Barthes
	class Reporter
		class Default
			def initialize(options)
				@options = options
			end

			def before_feature(num, name)
				puts "#{name} (##{num})"
			end

			def before_scenario(num, name, scenario, scenarios)
				puts ("\t" * scenarios.size) + "#{name} (##{num})"
			end

			def before_action(num, name, action, scenarios)
				print ("\t" * scenarios.size) + "#{name} (##{num})"
			end

			def after_action(num, name, action, scenarios, result)
				flag = ''
				if result.empty? || result.all? {|r| r[:result] == true }
					flag = 'OK'
				else
					flag = 'NG'
				end
				puts " -> #{flag}"
			end
		end
	end
end
