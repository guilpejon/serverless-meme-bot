tool "create-command" do
  flag :token, "--token TOKEN"

  def run
    require_relative "discord_api"

    client = DiscordApi.new(bot_token: token)
    definition = {
      name: 'random-subreddit-post',
      description: 'Fetch random top post from subreddit',
      options: [
        {
          type: 3,
          name: 'subreddit',
          description: 'Subreddit (e.g. `ProgrammerHumor`)',
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

tool "random-top-post" do
  required_arg :subreddit

  def run
    require_relative "reddit_api"
    client = RedditApi.new(subreddit: subreddit)
    result = client.formatted_post
    puts result
  end
end
