require 'functions_framework'
require_relative 'responder'

FunctionsFramework.on_startup do
  set_global(:responder, Responder.new)
end

FunctionsFramework.http 'discord_webhook' do |request|
  global(:responder).respond(request)
end
