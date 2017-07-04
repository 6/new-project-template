if Rails.application.secrets.aws_access_key_id.present?
  aws_access_key_id = Rails.application.secrets.aws_access_key_id
  aws_secret_access_key = Rails.application.secrets.aws_secret_access_key
  aws_region = Rails.application.secrets.aws_region

  credentials = Aws::Credentials.new(aws_access_key_id, aws_secret_access_key)

  aws_config = {
    region: aws_region,
    credentials: credentials,
  }
  Aws.config.update(aws_config)
end
