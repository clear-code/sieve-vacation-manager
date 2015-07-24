require "test-unit"
require "active_record"
require "active_support/core_ext/time"
require "fileutils"
require "pathname"
require "database_cleaner"
require "user"
require "sieve_filter_setting"

Time.zone_default = Time.find_zone!("Tokyo")
ActiveRecord::Base.default_timezone = :local

module TestHelper
  module Config
    def top_dir
      Pathname(__FILE__).dirname.parent
    end

    def log_dir
      top_dir + "log"
    end

    def app_config
      YAML.load_file(top_dir + "config/settings.yml")
    end

    def db_config
      YAML.load_file(top_dir + "config/database.yml")
    end
  end

  class Database
    include Config
    def prepare
      ActiveRecord::Base.establish_connection(db_config["test"])
    end

    def clear
      DatabaseCleaner.clean
      User.delete_all
    end
  end
end
