# Print Ruby version at startup
Pry.config.hooks.add_hook(:when_started, :say_hi) do
  puts "Using Ruby version #{RUBY_VERSION}"
end

# Require Sinatra application
top_dir = Pathname(__FILE__).dirname
lib_dir = top_dir + "lib"
$LOAD_PATH.unshift(lib_dir.to_s)
model_dir = top_dir + "models"
$LOAD_PATH.unshift(model_dir.to_s)

require "active_support/core_ext/time"
require "sieve-vacation-manager"
require "user"
require "sieve_filter_setting"
