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

require "user"

module UserModel
  class TestUser < Test::Unit::TestCase
    def setup
      DatabaseCleaner.start
    end

    def teardown
      DatabaseCleaner.clean
    end

    sub_test_case "email" do
      test "valid email" do
        user = User.new(email: "foobar@example.com")
        assert_true(user.valid_email?)
      end

      test "invalid email" do
        user = User.new(email: "alice")
        assert_false(user.valid_email?)
      end
    end

    sub_test_case "authenticate" do
      test "success" do
        user = User.new(email: "alice@example.com")
        actual = user.authenticate("test", app_config["managesieve-server"])
        assert_true(actual)
      end

      test "failure" do
        wrong_user = User.new(email: "wrong-user@example.com")
        actual = wrong_user.authenticate("test", app_config["managesieve-server"])
        assert_nil(actual)
      end
    end
  end
end
