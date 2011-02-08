# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Slam6DUI::Application.initialize!

server_yml = Pathname(__FILE__).dirname.join('server.yml')
AppConfig  = YAML.load(server_yml.read)[RAILS_ENV]