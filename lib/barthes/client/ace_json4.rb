require "barthes/client/ace"
require "jmespath"

class Barthes::Client::AceJson4 < Barthes::Client::Ace
	def initialize(env)
		super(env)
		@client = AceClient::Json4.new(@options)
	end

	def compare(response, expectation)
		result = nil
		case expectation['type']
		when 'response_code'
			result = response.code == expectation['value']
			{'result' => result, 'returned' => response.code, 'expected' => expectation['value']}
		when 'jmespath_value'
			text = jmespath(response, expectation['jmespath'])
			if expectation['method'].nil? || expectation['method'] == 'eq'
				result = (text == expectation['value'])
			elsif expectation['method'] == 'regexp'
				result = !(text.match Regexp.new(expectation['value'])).nil?
			elsif expectation['method'] == 'ne'
				result = (text != expectation['value'])
			end
			{'result' => result, 'returned' => text, 'expected' => expectation['value']}
		when 'jmespath_size'
			size = jmespath(response, expectation['jmespath']).size
			if expectation['method'].nil? || expectation['method'] == 'eq'
				result = (size == expectation['value'])
			elsif expectation['method'] == 'gt'
				result = (size > expectation['value'])
			elsif expectation['method'] == 'gte'
				result = (size >= expectation['value'])
			elsif expectation['method'] == 'lt'
				result = (size < expectation['value'])
			elsif expectation['method'] == 'lte'
				result = (size <= expectation['value'])
			end
			{'result' => result, 'returned' => size, 'expected' => expectation['value']}
		else
			{'result' => true}
		end
	end

	def extract(config, response)
		jmespath(response, config["jmespath"])
	end

	def jmespath(response, jmespath)
		JMESPath.search(jmespath, response.parsed_response)
	end
end
