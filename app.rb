require './app/models/gcap.rb'
require './app/models/category.rb'
require './app/models/event.rb'
require './app/models/entities.rb'
require './app/helpers/oauth.rb'
require './app/helpers/category.rb'
require './app/helpers/event.rb'
require './app/api/v1.rb'

module Calendar
   class API < Grape::API
      logger.formatter = GrapeLogging::Formatters::Default.new
      logger Logger.new GrapeLogging::MultiIO.new(STDOUT, File.open(Settings::LOG_PATH, 'a'))
      use GrapeLogging::Middleware::RequestLogger, { logger: logger }
      mount Calendar::V1 => '/calendar/v1'
   end
end
