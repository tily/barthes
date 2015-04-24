require 'barthes/runner'
require 'barthes/reporter/default'
require 'json'
require 'slop'

module Barthes
	class CLI
		def self.parse_options
			@opt = Slop.parse!(help: true) do
			  banner 'Usage: barthes [options] /path/to/some_spec.json'
			  on 'e', 'env',       'environment file paths',               argument: :optional, as: Array
			  on 'q', 'quiet',     'not show test details',                argument: :optional, as: :count
			  on 'f', 'from',      'test number to start from',            argument: :optional, as: Integer, default: 1
			  on 't', 'to',        'test number to stop to',               argument: :optional, as: Integer
			  on 'l', 'load',      'An optional password',                 argument: :optional
			  on 'd', 'dryrun',    'not run test but show just structure', argument: :optional, as: :count
			  on 'c', 'cache',     'cache path',                           argument: :optional, default: './barthes-cache.json'
			  on 'r', 'reporters', 'reporters to use',                     argument: :optional, as: Array
			  on 'j', 'junit-xml', 'junit xml output path',                argument: :optional
			  on 'g', 'tags',      'tags to filter actions',               argument: :optional, as: Array
			  on 'n', 'notags',    'tags to filter no actions',            argument: :optional, as: Array
			end
			@opt.to_hash
		end

		def self.start
			options = parse_options
			abort @opt.help if ARGV.empty?
			Runner.new(options).run(ARGV)
		end
	end
end
