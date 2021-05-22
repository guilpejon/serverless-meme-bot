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

# create a new application in discord
https://discord.com/developers/applications

#############################################
# SETTING DISCORD INTERACTIONS ENDPOINT URL #
#############################################

# Discord needs to send a request with {type:1} and receive it back to work
# https://discord.com/developers/docs/interactions/slash-commands#receiving-an-interaction

# test locally sending params
curl http://localhost:8080 --data '{"type":1}'

# Discord verifies request signatures with ED25519
# https://discord.com/developers/docs/interactions/slash-commands#security-and-authorization

# redeploy function
gcloud functions deploy discord_webhook

# set INTERACTIONS ENDPOINTS URL with the function url
https://discord.com/developers/applications/<ID>/information
