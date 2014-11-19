class Barthes::Client::AceQuery3 < Barthes::Client::Ace
        def initialize(env)
		super(env)
		@client = AceClient::Query3.new(@options)
        end
end
