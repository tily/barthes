require "bundler/gem_tasks"

desc 'vup'
task :vup do
	path = 'lib/barthes/version.rb'
	if version = ENV['VERSION']
		file = File.open(path, 'w')
		file.puts "module Barthes"
		file.puts "	VERSION = \"#{version}\""
		file.puts "end"
		file.close
		system "git add lib/barthes/version.rb"
		system "git commit -m 'version up to #{version}'"
		Rake::Task["release"].invoke
	else
		puts File.read(path)
	end
end
