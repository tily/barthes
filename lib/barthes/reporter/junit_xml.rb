require 'builder'
require 'nokogiri'

module Barthes
	class Reporter
		class JunitXml
			def initialize(opts={})
				@opts = opts
				@xml = Builder::XmlMarkup.new
				@xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
			end

			def after_run(features)
				result = @xml.testsuites do |xml|
					features.each do |feature|
						walk_json(feature)
					end
				end
				xml = Nokogiri::XML(result).to_xml(indent: 2)
				case @opts['output']
				when nil, '$stdout'
					$stdout.puts xml
				when '$stderr'
					$stderr.puts xml
				else
					File.open(@opts['output'], 'w') do |f|
						f.puts xml
					end
				end
			end

			def walk_json(json, parents=[]) 
				case json.first
				when 'feature'
					if json.last.class == Array
						@xml.testsuite(name: json[1], tests: json.last.size) do
							parents.push json[1]
							json.last.each do |child|
								walk_json(child, parents)
							end
							parents.pop
						end
					end
				when 'scenario'
					if json.last.class == Array
						parents.push json[1]
						json.last.each do |child|
							walk_json(child, parents)
						end
						parents.pop
					end
				when 'action'
					# TODO: zero padding with calculation
					name = "##{sprintf('%03d', json.last['number'])} #{parents.join(' > ')} #{json[1]}"
					@xml.testcase(name: name) do
						case json.last['status']
						when 'skipped'
							@xml.skipped
						when 'failure'
							failure = "failed expectations: \n"
							expectations = json.last['expectations'] || []
							expectations.each do |expectation|
								if expectation['result'] == false
									failure += JSON.pretty_generate(expectation) + "\n"
								end
							end
							@xml.failure failure
						when 'error'
							error = "error:\n"
							error += "class: #{json.last['error']['class']}\n"
							error += "message: #{json.last['error']['message']}\n"
							error += "backtrace: #{json.last['error']['backtrace'].join("\n")}\n"
							@xml.error error
						end
						if json.last['status'] != 'skipped' && json.last['request'] && json.last['response']
							stdout = "request:\n"
							stdout += "#{JSON.pretty_generate(json.last['request'])}\n"
							stdout += "response:\n"
							stdout += "#{JSON.pretty_generate(json.last['response'])}\n"
							@xml.tag!(:'system-out', stdout)
						end
					end
				else
					puts json
				end
			end
		end
	end
end

__END__
