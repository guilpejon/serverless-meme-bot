require_relative 'responder'
require 'functions_framework'

FunctionsFramework.on_startup do
  set_global(:responder, Responder.new)
end

FunctionsFramework.http 'discord_webhook' do |request|
  global(:responder).respond(request)
end
