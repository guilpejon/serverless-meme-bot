require 'json'
require 'ed25519'
require_relative "reddit_api"

class Responder
  # TODO, move to env var
  DISCORD_PUBLIC_KEY = 'b6505266203eb9db0a6167de3b598f11d8c46c1ce3275a24c6e1f3b24170cb6e'

  # Allowed difference in seconds betwen the current time and
  # the timestamp sent by Discord
  ALLOWED_CLOCK_SKEW = 10

  def initialize
    public_key = DISCORD_PUBLIC_KEY
    public_key_binary = [public_key].pack('H*')
    @verification_key = Ed25519::VerifyKey.new(public_key_binary)
  end

  def respond(rack_request)
    raw_body = rack_request.body.read

    unless valid_request?(raw_body, rack_request.env)
      return [401,
       {'Content-Type' => 'text/plain'},
       ['Invalid request signature']
      ]
    end

    interaction = JSON.parse(raw_body)

    case interaction['type']
    when 1
      # discord ping
      { type: 1 }
    when 2
      # command call
      handle_command(interaction)
    else
      [400,
       {'Content-Type' => "text/plain"},
       ['Unrecognized interaction type']
      ]
    end
  end

  private

  def handle_command(interaction)
    subreddit = subreddit_from_interaction(interaction)
    discord_post = RedditApi.new(subreddit: subreddit).formatted_post
    {
      type: 4,
      data: {
        content: discord_post
      }
    }
  end

  def subreddit_from_interaction(interaction)
    command_data = interaction["data"]

    raise "Unexpected command: #{command_data['name']}" unless command_data["name"] == "subreddit-random-post"

    command_data["options"].each do |option|
      if option["name"] == "subreddit"
        return option["value"]
      end
    end

    raise "No subreddit found"
  end

  # Verify a request by checking the timestamp and signature
  def valid_request?(raw_body, rack_env)
    # Get the timestamp and check for replay attacks
    timestamp = rack_env['HTTP_X_SIGNATURE_TIMESTAMP'].to_s
    current_time = Process.clock_gettime(Process::CLOCK_REALTIME)
    clock_skew = (current_time - timestamp.to_i).abs

    return false if clock_skew > ALLOWED_CLOCK_SKEW

    # Get the signature and verify it against the content and timestamp
    signature_hex = rack_env['HTTP_X_SIGNATURE_ED25519'].to_s
    signature = [signature_hex].pack('H*')

    begin
      @verification_key.verify(signature, timestamp + raw_body)
      true
    rescue Ed25519::VerifyError
      false
    end
  end
end
