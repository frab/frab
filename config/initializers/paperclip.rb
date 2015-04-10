# Set paperlicp defaults for amazon s3 storage
# See also https://devcenter.heroku.com/articles/paperclip-s3
if ENV["ENABLE_S3_STORAGE"] == "true"
  Frab::Application.config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: {
      bucket: ENV['S3_BUCKET_NAME'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  }
end
