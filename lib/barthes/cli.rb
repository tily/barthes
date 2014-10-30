require 'barthes/runner'
require 'barthes/reporter/default'
require 'json'
require 'thor'

module Barthes
	class CLI < Thor
		desc 'exec', 'execute tests from json files'
		option :environment, :type => :string, :aliases => :e 
		def exec(*paths)
			Runner.new(options).run(paths)
		end
	end
end
