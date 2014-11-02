
module Barthes
	class Cache
		@cache = {}

		class << self
			def load(cache)
                          @cache = cache
			end

			def reset
				@cache = {}
			end

			def get(key)
				@cache[key]
			end

			def set(key, value)
				@cache[key] = value
			end

			def to_hash
				@cache
			end
		end
	end
end
