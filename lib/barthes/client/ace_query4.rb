class Barthes::Client::AceQuery4 < Barthes::Client::Ace
        def initialize(env)
		super(env)
		@client = AceClient::Query4.new(@options)
        end
end

