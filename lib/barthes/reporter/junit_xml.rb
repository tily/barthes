require 'builder'
require 'nokogiri'

module Barthes
	class Reporter
		class JunitXml
			def initialize
				@xml = Builder::XmlMarkup.new
				@xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
			end

			def after_run(features)
				result = @xml.testsuites do |xml|
					features.each do |feature|
						walk_json(feature)
					end
				end
				puts Nokogiri::XML(result).to_xml(indent: 2)
			end

			def walk_json(json, parents=[]) 
				case json.first
				when 'feature', 'scenario'
					if json.last.class == Array
						@xml.testsuite(name: json[1], tests: json.last.size) do
							parents.push json[1]
							json.last.each do |child|
								walk_json(child, parents)
							end
							parents.pop
						end
					end
				when 'action'
					name = [parents, "##{json.last['number'].to_s} #{json[1]}"].join('.')
					@xml.testcase(name: name) do
						case json.last['status']
						when 'skipped'
							@xml.skipped
						when 'failure'
						when 'error'
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

			def render_testcase(xml, action)
				xml.testcase do
				end
			end
		end
	end
end

__END__
