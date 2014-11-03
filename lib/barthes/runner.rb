require 'json'
require 'barthes/action'
require 'barthes/reporter'
require 'barthes/cache'
require 'barthes/config'

module Barthes
	class Runner
		def initialize(options)
			Barthes::Config.update(options)
			load_cache
			load_libraries
			load_envs(options[:env])
			@reporter = Reporter.new
		end

		def load_cache
			if File.exists? Barthes::Config[:cache]
				Barthes::Cache.update JSON.parse File.read Barthes::Config[:cache]
			end
		end

		def load_libraries
			path = Dir.pwd + '/.barthes'
			load path if File.exists?(path)
		end

		def load_envs(env_paths)
			@env = {}
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
						feature_results = walk_json(json.last, [file])
						results += results
					end
				end
				results
			end
			if !Barthes::Cache.empty?
				File.write Barthes::Config[:cache], JSON.pretty_generate(Barthes::Cache) + "\n"
			end
		end

		def in_range?
			flag = @num >= Barthes::Config[:from]
			flag = flag && (@num >= Barthes::Config[:to]) if Barthes::Config[:to]
			flag
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
					handle_action(json, scenarios) if in_range?
					@num += 1
				else
					json.each do |element|
						walk_json(element, scenarios)
					end
				end
			end
		end
	
		def handle_scenario(scenario, scenarios)
			return if @failed
			@reporter.report(:scenario, @num, scenario[1], scenario.last, scenarios) do
			end
		end
	
		def handle_action(action, scenarios)
			return if @failed
			name, content = action[1], action.last
			env = @env.dup
			env.update(content['environment']) if content['environment']
			@reporter.report(:action, @num, name, action.last, scenarios) do
				if !Barthes::Config[:dryrun] && !@failed
					content = Action.new(env).action(content)
					if content['expectations'] && content['expectations'].any? {|e| e['result'] == false }
						@failed = true
					end
				end
				content
			end
		end
	end
end
