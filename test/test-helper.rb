# Copyright (C) 2015  ClearCode Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
