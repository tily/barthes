
module Barthes
	class Reporter
		class JunitXml
			def after_run(features)
				features.each do |feature|
				end
			end

			def walk_feature
			end

			def render_testcase(xml, action)
				xml.testcase do
					xml.stdout
					xml.failure
					xml.skipped
					xml.error
				end
			end
		end
	end
end

__END__
