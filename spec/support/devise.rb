RSpec.configure do |config|
  config.include(Devise::Test::ControllerHelpers, type: :controller)

  [:request, :feature].each do |type|
    config.include(Devise::Test::IntegrationHelpers, type:)
  end
end