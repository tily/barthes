
module Barthes
	class Reporter
		def initialize(options)
			@reporters = []
			if options[:reporter]
				reporter_classes = options[:reporter].split(',')
				reporter_classes.each do |klass_name|
					klass = Object.get_const(klass_name)
					@reporters << klass.new
				end
			else
				@reporters = [Reporter::Default.new(options)]
			end
		end

		def report(event, *args, &block)
			@reporters.each do |r|
				m = :"before_#{event.to_s}"
				r.send(m, *args) if r.respond_to?(m)
			end
	
			result = yield

			@reporters.each do |r|
				m = :"after_#{event.to_s}"
				args << result
				r.send(m, *args) if r.respond_to?(m)
			end
		end
	end
end
