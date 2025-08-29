require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Build and publish gem to RubyGems"
task :publish do
  puts "Building gem..."
  system("gem build smollama.gemspec")
  
  gem_file = Dir["smollama-*.gem"].first
  if gem_file
    puts "Publishing #{gem_file} to RubyGems..."
    system("gem push #{gem_file}")
    
    puts "Cleaning up..."
    File.delete(gem_file)
  else
    puts "No gem file found to publish!"
  end
end

desc "Build gem without publishing"
task :build do
  system("gem build smollama.gemspec")
end

desc "Install gem locally"
task :install => :build do
  gem_file = Dir["smollama-*.gem"].first
  if gem_file
    system("gem install #{gem_file}")
    File.delete(gem_file)
  end
end