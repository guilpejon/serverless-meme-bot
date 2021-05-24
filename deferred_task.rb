require_relative 'reddit_api'
require_relative 'discord_api'

class DeferredTask
  def initialize(bot_token:)
    @discord_api_client = DiscordApi.new(bot_token: bot_token)
  end

  def handle_event(event)
    # Get data from the Pub/Sub message
    attributes = event.data["message"]["attributes"]
    subreddit = attributes["subreddit"]
    reddit_api_client = RedditApi.new(subreddit: subreddit)
    interaction_token = attributes["token"]

    result = reddit_api_client.formatted_post

    # Edit the original interaction response to signal we're done "thinking"
    @discord_api_client.edit_interaction_response(
      interaction_token, "Found a top post for subreddit #{subreddit}!"
    )

    @discord_api_client.create_followup(interaction_token, result)
  end
end
