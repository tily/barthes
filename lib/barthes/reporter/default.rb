
module Barthes
	class Reporter
		class Default
			def before_scenario(params, hoge)
				p params
			end

			def after_action(params, hoge, fuga)
				p params
				#p params
			end
		end
	end
end
