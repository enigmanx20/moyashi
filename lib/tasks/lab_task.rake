namespace :lab_task do
  desc "DB data migration from fuNalyzer sinatra version."
  task db_migration: :environment do
    # It' ok that writing require here because rake files will load before run Bundler.
    # So you can write like this. 
    #   require File.dirname(__FILE__) + '/test.rb'
    require 'YAML'

    puts "inporting dump data to DB..."

    source = File.read(Rails.root.join('db','dump_sinatra.yml'))
    sinatra_db = YAML.dump(source)

    
  end

end
