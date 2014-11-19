require 'pg'
require 'barthes/client/rdb'

class Barthes::Client::Pgsql < Barthes::Client::Rdb
  def initialize(env)
     @client = PG::connect(
       host: env['host'],
       user: env['user'],
       password: env['password'],
       dbname: env['database'],
       sslmode: 'disable'
     )
  end

  def execute_query(query)
    @client.exec(query)
  end
end
