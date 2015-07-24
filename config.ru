require "pathname"

top_dir = Pathname(__FILE__).dirname
lib_dir = top_dir + "lib"
$LOAD_PATH.unshift(lib_dir.to_s)
model_dir = top_dir + "models"
$LOAD_PATH.unshift(model_dir.to_s)

require "rack"
require "rack/contrib"

require "sieve-vacation-manager"
require "user"
require "sieve_filter_setting"

use Rack::Locale
I18n.enforce_available_locales = false
I18n.config.available_locales = [:en, :ja, :"en-us", :"en-US", :"ja-jp", :"ja-JP"]
I18n.config.default_locale = :en
I18n.load_path = Dir[top_dir + "config/locale/*.yml"]
run SieveVacationManager::App
