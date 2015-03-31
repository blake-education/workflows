# encoding: UTF-8
require 'rubygems'
require 'rake'
require 'rspec'
require 'rspec/core/rake_task'

begin
      require 'bundler/setup'
rescue LoadError
      puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'fileutils'

RSpec::Core::RakeTask.new(:ruby_spec) do |spec|
      spec.pattern = './spec/**/*_spec.rb'
end

task :default => [:ruby_spec]
