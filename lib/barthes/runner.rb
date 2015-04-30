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
			@env = {}
			load_envs(options[:env]) if options[:env]
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
			begin
				files = expand_paths(paths, '_spec.json')
				results = []
				@reporter.report(:run, results) do
					@num = 1
					files.each do |file|
						json = JSON.parse File.read(file)
						@reporter.report(:feature, json[1]) do
							walk_json(json.last, [file])
							results << json
							json
						end
					end
					results
				end
			rescue StandardError => e
				raise e
			ensure
				if !Barthes::Cache.empty?
					File.write Barthes::Config[:cache], JSON.pretty_generate(Barthes::Cache) + "\n"
				end
			end
			exit @failed ? 1 : 0
		end

		def in_range?
			flag = @num >= Barthes::Config[:from]
			flag = flag && (@num <= Barthes::Config[:to]) if Barthes::Config[:to]
			flag
		end
	
		def walk_json(json, scenarios)
			if json.class == Array
				case json.first
				when 'scenario'
					handle_scenario(json, scenarios)
					scenarios.push(json.first)
					walk_json(json.last, scenarios)
					scenarios.pop
				when 'action'
					json.last['status'] = 'skipped' if Barthes::Config[:dryrun] > 0
					json.last['number'] = @num
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
			@reporter.report(:scenario, scenario[1], scenario.last, scenarios) do
				scenario.last
			end
		end
	
		def handle_action(action, scenarios)
			return if @failed
			name, content = action[1], action.last
			env = @env.dup
			env.update(content['env']) if content['env']
			@reporter.report(:action, name, action.last, scenarios) do
				if Barthes::Config[:dryrun] == 0 && !@failed && tagged?(env)
					content = Action.new(env).action(content)
					@failed = true if %w(failure error).include?(content['status'])
				end
				if !tagged?(env)
					content['status'] = 'skipped'
				end
				content
			end
		end

		def tagged?(env)
			return true if Barthes::Config[:tags].nil? && Barthes::Config[:'no-tags'].nil?
			tags = env['tags'] || []
			if Barthes::Config[:tags].nil?
				if (Barthes::Config[:'no-tags'] & tags).size > 0
					flag = false
				else
					flag = true
				end
			else
				flag = (Barthes::Config[:tags] & tags).size > 0
			end
		end
	end
end
