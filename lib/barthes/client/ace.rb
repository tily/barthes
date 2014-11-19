require 'ace-client'
require 'barthes/client/httparty'
require 'active_support/core_ext/hash/keys'

class AceClient::Base
	query_string_normalizer proc { |query|
		query.map do |key, value|
			"#{CGI.escape key}=#{CGI.escape value}"
		end.join('&')
	}
end

class Barthes::Client::Ace < Barthes::Client::HTTParty
	OPTION_KEYS = %w(
		authorization_key
		signature_method
		authorization_prefix
		service
		region
		host
		nonce
		access_key_id_key
		path
		use_ssl
		endpoint
		response_format
		http_method
		access_key_id
		secret_access_key
		timeout
	)

	def initialize(env)
		# TODO: validate existence of required options
		@options = env.slice(*OPTION_KEYS).symbolize_keys
		if env['client'] && env['client']['user']
			@user = env['client']['user']
			@options[:access_key_id] = env["#{@user}.access_key_id"]
			@options[:secret_access_key] = env["#{@user}.secret_access_key"]
			@options.update(env['client'].slice(*OPTION_KEYS).symbolize_keys)
		end
	end

	def action(params)
		params = params.dup
		action = params.delete('Action')
		params ||= {}
		response = @client.action(action, params)
		response
	end
end
