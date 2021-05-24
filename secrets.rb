require "psych"
require "google/cloud/secret_manager"

class Secrets
  SECRETS_FILE = File.join(__dir__, "secrets.yaml")
  SECRET_NAME = "discord-bot-secrets"
  PROJECT_ID = "it-memes-bot"

  def initialize
    if File.file?(SECRETS_FILE)
      load_from_file
    else
      load_from_secret_manager
    end
  end

  attr_reader :discord_application_id,
              :discord_guild_id,
              :discord_public_key,
              :discord_bot_token

  def load_from_file
    secret_data = Psych.load_file(SECRETS_FILE)
    load_from_hash(secret_data)
  end

  def load_from_secret_manager
    secret_manager = Google::Cloud::SecretManager.secret_manager_service
    version_name = secret_manager.secret_version_path(
      project: PROJECT_ID, secret: SECRET_NAME, secret_version: "latest"
    )
    version_data = secret_manager.access_secret_version(name: version_name)
    secret_data = Psych.load(version_data.payload.data)
    load_from_hash(secret_data)
  end

  def load_from_hash(hash)
    @discord_application_id = hash["discord_application_id"]
    @discord_guild_id = hash["discord_guild_id"]
    @discord_public_key = hash["discord_public_key"]
    @discord_bot_token = hash["discord_bot_token"]
  end
end
