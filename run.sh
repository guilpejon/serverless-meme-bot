# create a project on google cloud

# enable google cloud build API
https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com?project=it-memes-bot

# create FaaS
gcloud functions deploy discord_webhook \
    --project=it-memes-bot --region=us-central1 \
    --trigger-http --entry-point=discord_webhook \
    --runtime=ruby27 --allow-unauthenticated
curl <GIVEN_URL>

# test locally
bundle exec functions-framework-ruby --target discord_webhook
curl http:localhost:8080


