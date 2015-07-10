# config.ru

require File.expand_path('../environment', __FILE__)
use ActiveRecord::ConnectionAdapters::ConnectionManagement
require File.expand_path('../app', __FILE__)

run Calendar::API
