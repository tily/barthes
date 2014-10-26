# TODO: json includesion
require 'erubis'
require 'ostruct'

module Barthes
	class Converter
		module Helpers
			def resolve_value(value)
				value = value.gsub(/\@\{(.+?)\}/) { '#{' + "$store['#{$1}']" + '}' }
				value = value.gsub(/\$\{(.+?)\}/) { '#{' + "@env['#{$1}']" + '}' }
				"%Q{#{value}}"
			end
		end

		def initialize(name, json)
			@name = name
			@json = json
		end

		def template(name)
			here = File.dirname(__FILE__)
			File.read(here + "/templates/#{name.to_s}.erb")
		end

		def render(template_name, indent, opts={}, &block)
			opts[:block] = block
			code = Erubis::Eruby.new(template(template_name)).result(
			  OpenStruct.new(opts).instance_eval { extend Helpers; binding }
			)
		 	code = code.split(/\n/).join("\n" + ("\t" * indent)) if indent
			code
		end

		def convert(json)
			render(:describe, 0, :name => @name) do
				walk_json(json)
			end
		end

		def walk_json(arr)
			return if arr.class != Array
			rendered = []
			case arr.first
			when 'it'
				arr.last['_sleep'] = arr.last['sleep']
				arr.last['name'] = arr[1]
				rendered << render(:it, 1, arr.last) do
					walk_expectations(arr.last['expectations'], false).join(" && ")
				end
			when 'context'
				rendered << render(:context, 1, :name => arr[1]) do
					walk_json(arr.last)
				end
			else
				arr.each do |elem|
					rendered << walk_json(elem)
				end
			end
			rendered.join("\n\t")
		end

		# TODO: timeout
		def walk_expectations(arr, in_or)
			return if arr.nil?
			rendered = []
			arr.each do |elem|
				if elem.class == Array
					rendered << walk_expectations(elem, in_or).join(" && ")
				elsif elem.keys.first == 'Or'
					rendered << walk_expectations(elem.values, true).join(' || ')
				elsif elem['type'] == 'Value' || elem['type'] == 'StringComarison'
					rendered << render(:'expectations/xpath_value', 2, elem)
				end
			end
			rendered
		end

	end
end
