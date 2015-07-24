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

require "sieve-vacation-manager/app"
require "sieve-vacation-manager/version"
require "open3"

module SieveVacationManager
  class TestSieveFilter < Test::Unit::TestCase
    include TestHelper::Config
    def setup
      unless sieve_test_avaiable?
        omit("TestSieveFilter depends on \"sieve-test\" command. Skip.")
      end
      @mail_file = top_dir + "test/fixture/empty.eml"
    end

    def teardown
    end

    def assert_valid_filter(relative_path)
      sieve_filter = top_dir + relative_path
      _, _, status =  Open3.capture3("sieve-test #{sieve_filter} #{@mail_file}")
      assert_true(status.success?)
      svbin_path = sieve_filter.sub(/\.sieve\z/, ".svbin")
      FileUtils.rm_rf(svbin_path)
    end

    class TestExampleFilters < self
      def test_from_is_internal_filter
        assert_valid_filter("test/fixture/from-is-internal.sieve")
      end

      def test_redirect_with_date_range
        assert_valid_filter("test/fixture/redirect-with-date-range.sieve")
      end

      def test_full
        assert_valid_filter("test/fixture/full.sieve")
      end
    end

    private
    def sieve_test_avaiable?
      _, _, status =  Open3.capture3("which sieve-test")
      status.exitstatus == 0
    end
  end
end
