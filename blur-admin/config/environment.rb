# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
BlurAdmin::Application.initialize!

BlurAdmin::Application.configure do
  config.gem "authlogic"
end
