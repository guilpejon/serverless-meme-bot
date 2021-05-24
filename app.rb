require 'functions_framework'
require_relative 'responder'

FunctionsFramework.on_startup do
  # Define how to construct a Responder
  set_global(:responder) do
    # This does not actually run until the discord_webhook
    # function actually accesses it.
    require_relative "responder"
    Responder.new
  end

  # Define how to construct a DeferredTask
  set_global(:deferred_task) do
    # This does not actually run until the discord_subscriber
    # function actually accesses it.
    require_relative "secrets"
    require_relative "deferred_task"
    secrets = Secrets.new
    DeferredTask.new(bot_token: secrets.discord_bot_token)
  end
end

FunctionsFramework.http 'discord_webhook' do |request|
  global(:responder).respond(request)
end

FunctionsFramework.cloud_event "discord_subscriber" do |event|
  global(:deferred_task).handle_event(event)
end
