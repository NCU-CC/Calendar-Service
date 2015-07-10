#!/usr/bin/env rake
require 'bundler/setup'
require 'grape/activerecord/rake'

namespace :db do
   task :environment do
      require './environment.rb'
      require_relative 'app'
   end
end
