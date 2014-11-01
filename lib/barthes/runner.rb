require 'json'
require 'barthes/action'
require 'barthes/reporter'
require 'barthes/cache'

module Barthes
	class Runner
		def initialize(options)
			load_config
			load_environments(options[:environment])
			@reporter = Reporter.new(options)
			@options = options
		end

		def load_config
			path = Dir.pwd + '/.barthes'
			load path if File.exists?(path)
		end

		def load_environments(environment)
			@env = {}
			env_paths = environment.split(',')
			env_paths.each do |path|
				@env.update JSON.parse File.read(path)
			end
		end

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

		def run(paths)
			files = expand_paths(paths, '_spec.json')
			@reporter.report(:run, files) do
				@num = 1
				results = []
				files.each do |file|
					json = JSON.parse File.read(file)
					@reporter.report(:feature, @num, json[1]) do
						@num += 1
						Barthes::Cache.reset
						feature_results = walk_json(json.last, [file])
						results += results
					end
				end
				results
			end
		end
	
		def walk_json(json, scenarios)
			if json.class == Array
				case json.first
				when 'scenario'
					handle_scenario(json, scenarios)
					@num += 1
					scenarios.push(json.first)
					walk_json(json.last, scenarios)
					scenarios.pop
				when 'action'
					handle_action(json.last, scenarios)
					@num += 1
				else
					json.each do |element|
						walk_json(element, scenarios)
					end
				end
			end
		end
	
		def handle_scenario(scenario, scenarios)
			@reporter.report(:scenario, @num, scenario[1], scenario.last, scenarios) do
			end
		end
	
		def handle_action(action, scenarios)
			env = @env.dup
			env.update(action['env']) if action[1]['env']
			@reporter.report(:action, @num, action[1], action.last, scenarios) do
				if @options[:dryrun]
					[{result: true}]
				else
					results = Action.new(env).action(action.last)
					@failed = true if results.any? {|r| r[:result] == false }
					results
				end
			end
		end
	end
end
