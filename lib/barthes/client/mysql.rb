require 'mysql2'
require 'barthes/client/rdb'

class Barthes::Client::Mysql < Barthes::Client::Rdb
	def initialize(env)
		@client = Mysql2::Client.new(
		  host: env['host'],
		  username: env['user'],
		  password: env['password'],
		  database: env['database']
		)
	end
	
	def execute_query(query)
		@client.query(query)
	end
end
