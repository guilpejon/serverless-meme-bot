tool "create-command" do
  flag :token, "--token TOKEN"

  def run
    require_relative "discord_api"

    client = DiscordApi.new(bot_token: token)
    definition = {
      name: 'meme',
      description: 'Meme lookup',
      options: [
        {
          type: 3,
          name: 'reference',
          description: 'Meme reference (e.g. `IT`)',
          required: true
        }
      ]
    }
    result = client.create_command(definition)

    puts JSON.pretty_generate(result)
  end
end

tool 'list-commands' do
  flag :token, '--token TOKEN'

  def run
    require_relative 'discord_api'

    client = DiscordApi.new(bot_token: token)
    result = client.list_commands

    puts JSON.pretty_generate(result)
  end
end
