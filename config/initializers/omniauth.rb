Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["google_api_key"], ENV["google_api_secret"], { access_type: "offline", approval_prompt: "" }
end