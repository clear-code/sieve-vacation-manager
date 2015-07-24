source "https://rubygems.org/"

gem "rake"
gem "sinatra"
gem "sinatra-contrib"
gem "gettext"
gem "locale"
gem "rack-contrib"
gem "rack-flash3"
gem "mysql2"
gem "activesupport"
gem "activerecord"
gem "sinatra-activerecord"
gem "validates_email_format_of"
gem "ruby-managesieve", git: "git@github.com:andrenth/ruby-managesieve.git", branch: "master"

group :development do
  gem "rubocop", require: false
  gem "rerun"
end

group :test, :development do
  # gem "factory_girl"
end

group :test do
  gem "rack-test", require: "rack/test"
  gem "capybara"
  gem "poltergeist"
  gem "test-unit"
  gem "test-unit-notify"
  gem "test-unit-rr"
  gem "test-unit-capybara"
  gem "database_cleaner"
  gem "pry"
end
