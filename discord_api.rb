require 'faraday'
require 'json'
require_relative "secrets"

class DiscordApi
  DISCORD_APPLICATION_ID = Secrets.new.discord_application_id
  DISCORD_GUILD_ID = Secrets.new.discord_guild_id

  def initialize(bot_token: )
    @client_id = DISCORD_APPLICATION_ID
    @guild_id = DISCORD_GUILD_ID
    @bot_token = bot_token
  end

  def list_commands
    call_api("/applications/#{@client_id}/guilds/#{@guild_id}/commands")
  end

  def create_command(command_definition)
    definition_json = JSON.dump(command_definition)
    headers = {'Content-Type' => 'application/json'}

    call_api(
      "/applications/#{@client_id}/guilds/#{@guild_id}/commands",
      method: :post,
      body: definition_json,
      headers: headers
    )
  end

  private

  def call_api(
    path,
    method: :get,
    body: nil,
    params: nil,
    headers: nil
  )
    faraday = Faraday.new(url: 'https://discord.com') do |conn|
      # Set the authorization header to include a token of type "Bot"
      conn.authorization(:Bot, @bot_token)
    end

    response = faraday.run_request(method, "/api/v9#{path}", body, headers) { |req| req.params = params if params }

    raise "Discord API failure: #{response.status} #{response.body.inspect}" unless (200...300).cover?(response.status)

    return nil if response.body.nil? || response.body.empty?

    JSON.parse(response.body)
  end
end
