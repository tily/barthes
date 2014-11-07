require 'httparty'
require 'nokogiri'

module Barthes
	module Client
		class HTTParty
			include ::HTTParty

			def initialize(env)
				@env = env
				set_proxy
			end

			def set_proxy
				if proxy_uri = ENV['HTTP_PROXY']
					uri = URI.parse(proxy_uri)
					self.class.http_proxy uri.host, uri.port
				end
			end

			def action(params)
				url = @env['path'] ? @env['endpoint'] + @env['path'] : @env['endpoint']
				headers = @env['header'] ? @env['header'] : {}
				self.class.post(url, query: params)
			end

			def compare(response, expectation)
				result = nil
				case expectation['type']
				when 'response_code'
					result = response.code == expectation['value']
					{'result' => result, 'returned' => response.code, 'expected' => expectation['value']}
				when 'xpath_value'
					text = xpath(response, expectation['xpath']).text
					if expectation['method'].nil? || expectation['method'] == 'eq'
						result = (text == expectation['value'])
        		                elsif expectation['method'] == 'regexp'
						result = !(text.match Regexp.new(expectation['value'])).nil?
					elsif expectation['method'] == 'ne'
						result = (text != expectation['value'])
					end
					{'result' => result, 'returned' => text, 'expected' => expectation['value']}
				when 'xpath_size'
					size = xpath(response, expectation['xpath']).size
					if expectation['method'].nil? || expectation['method'] == 'eq'
						result = (size == expectation['value'])
					elsif expectation['method'] == 'gt'
						result = (size > expectation['value'])
					end
					{'result' => result, 'returned' => size, 'expected' => expectation['value']}
				else
					{'result' => true}
				end
			end

			def extract(config, response)
				if config['xpath']
					xpath(response, config['xpath']).text
				end
			end

			def xpath(response, xpath)
				doc = Nokogiri::XML response.body.gsub(/xmlns="(.+?)"/, '')
				doc.xpath(xpath)
			end
		end
	end
end
