####################
# HELLO WORLD FAAS #
####################

# create a project on google cloud
# enable google cloud build API in it
https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com?project=<name_of_project>

# install google cloud sdk
https://cloud.google.com/sdk/docs/quickstart

# create FaaS
gcloud functions deploy discord_webhook \
    --project=<name_of_project> --region=us-central1 \
    --trigger-http --entry-point=discord_webhook \
    --runtime=ruby27 --allow-unauthenticated
curl <GIVEN_URL>

# test locally
bundle exec functions-framework-ruby --target discord_webhook
curl http://localhost:8080

#######################
# DISCORD APPLICATION #
#######################

# create a new application in discord
https://discord.com/developers/applications

# Discord needs to send a request with {type:1} and receive it back to work
https://discord.com/developers/docs/interactions/slash-commands#receiving-an-interaction

# test locally sending params
curl http://localhost:8080 --data '{"type":1}'

# Discord verifies request signatures with ED25519
https://discord.com/developers/docs/interactions/slash-commands#security-and-authorization

# redeploy function
gcloud functions deploy discord_webhook

# set INTERACTIONS ENDPOINTS URL with the function url
https://discord.com/developers/applications/<APPLICATION_ID>/information

########################
# DISCORD BOT SKELETON #
########################

# create the bot
https://discord.com/developers/applications/<APPLICATION_ID>/bot

# add the bot to a server with the bot and application.commands permissions
https://discord.com/api/oauth2/authorize?client_id=<APPLICATION_ID>&scope=bot%20applications.commands

# to get the discord guild (server) ID, used in discord_api.rb
# In Discord, open your User Settings by clicking the Settings Cog next to your user name on the bottom.
# Go to Appearance and enable Developer Mode under the Advanced section, then close User Settings.
# Open your Discord server, right-click on the server name, then select Copy ID.

# install the gem toy to run ruby scripts
gem install toys

# BOT_TOKEN can be found in https://discord.com/developers/applications/<APPLICATION_ID>/bot
toys list-commands --token=$BOT_TOKEN

# documentation for creating a /command in a single server (guild)
https://discord.com/developers/docs/interactions/slash-commands#applicationcommand

# create a command
toys create-command --token=$BOT_TOKEN

# call on discord
/random-subreddit-post subreddit: ProgrammerHumor

##########
# REDDIT #
##########

# test locally
toys random-top-post ProgrammerHumor

# simulate discord request locally
curl http://localhost:8080 --data '{"type":2,"data":{"name":"subreddit-random-post","options":[{"name":"subreddit","value":"ProgrammerHumor"}]}}'

###########
# SECRETS #
###########

# deploy secrets do gcloud
gcloud secrets create discord-bot-secrets \
    --project=$MY_PROJECT --data-file=secrets.yaml

# grant access so our code can use the secrets
gcloud secrets add-iam-policy-binding discord-bot-secrets \
    --project=$MY_PROJECT --role=roles/secretmanager.secretAccessor \
    --member=serviceAccount:$MY_PROJECT@appspot.gserviceaccount.com

###########
# PUB/SUB #
###########

# create a topic to publish to
gcloud pubsub topics create discord-bot-topic --project=$MY_PROJECT

# deploy has to be done for each function in app.rb
# to deploy the new function and set it to run when a message is published in
# the topic we just created, use the following command
gcloud functions deploy discord_subscriber \
    --project=$MY_PROJECT --region=us-central1 \
    --trigger-topic=discord-bot-topic --entry-point=discord_subscriber \
    --runtime=ruby27

# publish a message on the topic we created to test it out
gcloud pubsub topics publish discord-bot-topic \
    --project=$MY_PROJECT --message=hello
