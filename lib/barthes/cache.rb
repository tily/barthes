
module Barthes
	class Cache
		@cache = {}

		class << self
			def reset
				@cache = {}
			end

			def get(key)
				@cache[key]
			end

			def set(key, value)
				@cache[key] = value
			end
		end
	end
end
