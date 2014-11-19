require 'barthes/client/ace'

class Barthes::Client::AceQuery2 < Barthes::Client::Ace
        def initialize(env)
		super(env)
		@client = AceClient::Query2.new(@options)
        end
end
