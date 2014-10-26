require 'barthes/converter'
require 'json'
require 'thor'
require 'rspec'

module Barthes
	class CLI < Thor
		desc 'convert', 'convert json into rspec'
		def convert(*paths)
			files = expand_paths(paths, '.json')
			files.each do |file|
				json = JSON.parse File.read(file)
				converter = Barthes::Converter.new(file, json)
				spec = converter.convert(json)
				File.write("#{file.gsub(/.json$/, '')}_spec.rb", spec)
			end
		end

		desc 'exec', 'execute tests from json files'
		option :rspec, :type => :string, :aliases => :r
		option :environment, :type => :string, :aliases => :e 
		def exec(*paths)
			ENV['BARTHES_ENV_PATH'] = options[:environment] if options[:environment]
			convert(*paths)
			paths = expand_paths(paths, '.json').map {|path| "#{path.gsub(/.json$/, '')}_spec.rb" }
			paths += options[:rspec].split(/\s/) if options[:rspec]
			RSpec::Core::Runner.run(paths)
		end

		no_commands do
			def expand_paths(paths, suffix)
				files = []
				if paths.empty?
					files += Dir["./**/*#{suffix}"]
				else
					paths.each do |path|
						if FileTest.directory?(path)
							files += Dir["#{path}/**/*#{suffix}"]
						elsif FileTest.file?(path)
							files << path
						end
					end
				end
				files
			end
		end
	end
end
