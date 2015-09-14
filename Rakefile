#!/usr/bin/env rake

require 'bundler/setup'
require 'grape/activerecord/rake'

namespace :db do
   ERROR = 1
   task :environment do
      require './environment.rb'
      require_relative 'app'
   end
end

namespace :csv do

   task :import, [:csv_file] do |t, args|
      require 'csv'
      require 'json'
      require './environment.rb'
      require './app/models/gcap.rb'
      require './app/models/category.rb'
      require './app/models/event.rb'
      require './app/helpers/category.rb'
      require './app/helpers/event.rb'

      include NCU::Category::Helpers
      include NCU::Event::Helpers

      if args.csv_file.nil?
         import_fail 'No Input File.'
         next
      end
      puts 'File Path: ' + args.csv_file
      csv_file = CSV.read(args.csv_file, :encoding => 'utf-8')
      @this_token = Hash.new
      @this_token['user'], @this_token['name'], @this_token['unit'] = csv_file[0]
      puts JSON.generate @this_token
      i = 1
      csv_file[1..-1].each do |row|
         i = i + 1
         event = Hash.new
         event[:summary], event[:description], event[:link], event[:location], event[:category], event[:start], event[:end] = row
         puts JSON.generate event
         result = import_event event
         if result == ERROR
            puts "#{args.csv_file}:#{i}"
            next
         end
         puts JSON.generate result
      end
   end

   def gcap
      @gcap ||= Gcap.new
   end

   def import_event event
      category = category_by_name event[:category]
      if category.nil?
         import_fail 'invalid_category'
         return ERROR
      end
      result = gcap.insert to_google(event), category['calendar_id']
      if result.error?
         import_fail result.error_message
         return ERROR
      end
      event[:id] = result.data.id
      event[:creator] = @this_token['user']
      insert_event event
   end

   def import_fail reason
      puts 'Failed: ' + reason
   end
end
