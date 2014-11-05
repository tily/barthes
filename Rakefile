require "bundler/gem_tasks"

desc 'vup'
task :vup do
	version = ENV['VERSION']
	File.open('lib/barthes/version.rb', 'w') do |f|
		f.write <<-EOF
module Barthes
	VERSION = "#{version}"
end
		EOF
	end
	system "git add lib/barthes/version.rb"
	system "git commit -m 'version up to #{version}'"
	system "git push origin master"
	system "git push --tags"
	system "rake build"
	system "gem push pkg/barthes-#{version}.gem"
end
