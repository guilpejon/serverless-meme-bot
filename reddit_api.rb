require 'faraday'
require 'json'

class RedditApi
  def initialize(subreddit:)
    @subreddit = subreddit
  end

  def formatted_post
    "#{random_top_post["title"]} - #{random_top_post["url_overridden_by_dest"]}"
  end

  private

  def random_top_post
    resource = "r/#{@subreddit}/top.json"
    response_object = call_api(resource)
    response_object["children"].sample["data"]
  end

  def call_api(path)
    response = Faraday.get("https://www.reddit.com/#{path}")

    body = JSON.parse(response.body)
    raise body["message"] || "Unknown error" unless response.status == 200 && body["data"]

    body["data"]
  end
end
