require 'barthes/runner'
require 'barthes/reporter/default'
require 'json'
require 'thor'
require 'slop'

module Barthes
	class CLI
		def self.parse_options
			opt = Slop.parse!(help: true) do
			  banner 'Usage: barthes [options]'
			  on 'e', 'env',       'environment file paths',               argument: :optional, as: Array
			  on 'q', 'quiet',     'not show test details',                argument: :optional
			  on 'f', 'from',      'test number to start from',            argument: :optional
			  on 't', 'to',        'test number to stop to',               argument: :optional
			  on 'l', 'load',      'An optional password',                 argument: :optional
			  on 'd', 'dryrun',    'not run test but show just structure', argument: :optional
			  on 'r', 'reporters', 'reporters to use',                     argument: :optional, as: Array
			end
			opt.to_hash
		end

		def self.start
			options = parse_options
			Runner.new(options).run(ARGV)
		end
	end
end
