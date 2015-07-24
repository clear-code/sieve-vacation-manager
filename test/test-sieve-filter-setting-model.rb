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

require "sieve_filter_setting"

module SieveFilterSettingModel
  class TestSieveFilterSetting < Test::Unit::TestCase
    def setup
      DatabaseCleaner.start
    end

    def teardown
      DatabaseCleaner.clean
    end

    class TestEscapeSieveString < self
      def test_escape_quote
        string = "This is a \"pen\"."
        expected = "This is a \\\"pen\\\"."
        actual = SieveFilterSetting.escape_sieve_string(string)
        assert_equal(expected, actual)
      end

      def test_escape_backslash
        string = "c:\\program files\\"
        expected = "c:\\\\program files\\\\"
        actual = SieveFilterSetting.escape_sieve_string(string)
        assert_equal(expected, actual)
      end
    end

    class GenerateSieveFilter < self
      def test_empty
        my_address = "suzuki@example.com"
        setting = SieveFilterSetting.new
        expected = ""
        assert_equal(expected, setting.to_sieve_script(my_address: my_address))
      end

      def test_forward
        my_address = "suzuki@example.com"
        today = Time.zone.now
        expired_day = Time.zone.now + 7.days.next
        zone = today.strftime("%z")
        setting = SieveFilterSetting.new
        setting.begin_at = today
        setting.end_at = expired_day
        setting.forward = true
        setting.forwarding_address = "foo@example.com"
        expected = <<-EOS
require "date";
require "relational";
if allof (currentdate :value "ge" :zone "#{zone}" "iso8601" "#{today.iso8601}",
          currentdate :value "le" :zone "#{zone}" "iso8601" "#{expired_day.iso8601}") {
  redirect "foo@example.com";
}
keep;
        EOS
        assert_equal(expected, setting.to_sieve_script(my_address: my_address))
      end

      def test_vacation_reply_to_all
        my_address = "suzuki@example.com";
        subject = "Vacation"
        body =
          "I'm on a vacation.\n" +
          "I'll return next week.\n" +
          "-- \n" +
          "\"Ichiro Suzuki\" <suzuki@example.com>\n"
        today = Time.zone.now
        expired_day = Time.zone.now + 7.days.next
        zone = today.strftime("%z")

        setting = SieveFilterSetting.new
        setting.begin_at = today
        setting.end_at = expired_day
        setting.vacation = true
        setting.reply_options = "all"
        setting.subject = subject;
        setting.body = body;

        expected = <<-EOS
require "date";
require "relational";
require "vacation";
if allof (currentdate :value "ge" :zone "#{zone}" "iso8601" "#{today.iso8601}",
          currentdate :value "le" :zone "#{zone}" "iso8601" "#{expired_day.iso8601}") {
  if true {
    vacation
      :days 1
      :subject "#{subject}"
      :addresses ["#{my_address}"]
"I'm on a vacation.
I'll return next week.
-- 
\\"Ichiro Suzuki\\" <suzuki@example.com>
";
  }
}
keep;
        EOS
        assert_equal(expected, setting.to_sieve_script(my_address: my_address))
      end


      def test_vacation_fixed_phrase
        my_address = "suzuki@example.com";
        fixed_phrase = %Q("Fixed phrase.")
        subject = "Vacation"
        body =
          "I'm on a vacation.\n" +
          "I'll return next week.\n" +
          "-- \n" +
          "\"Ichiro Suzuki\" <suzuki@example.com>\n"
        today = Time.zone.now
        expired_day = Time.zone.now + 7.days.next
        zone = today.strftime("%z")

        setting = SieveFilterSetting.new
        setting.begin_at = today
        setting.end_at = expired_day
        setting.vacation = true
        setting.reply_options = "all"
        setting.subject = subject;
        setting.body = body;

        expected = <<-EOS
require "date";
require "relational";
require "vacation";
if allof (currentdate :value "ge" :zone "#{zone}" "iso8601" "#{today.iso8601}",
          currentdate :value "le" :zone "#{zone}" "iso8601" "#{expired_day.iso8601}") {
  if true {
    vacation
      :days 1
      :subject "#{subject}"
      :addresses ["#{my_address}"]
"\\"Fixed phrase.\\"
I'm on a vacation.
I'll return next week.
-- 
\\"Ichiro Suzuki\\" <suzuki@example.com>
";
  }
}
keep;
        EOS
        actual = setting.to_sieve_script(my_address: my_address,
                                         fixed_phrase: fixed_phrase)
        assert_equal(expected, actual)
      end

      def test_vacation_reply_to_internal
        my_address = "suzuki@example.com";
        domains = ["example.com", "example.co.jp", "example.net"]
        subject = "Vacation"
        body =
          "I'm on a vacation.\n" +
          "I'll return next week.\n" +
          "-- \n" +
          "\"Ichiro Suzuki\" <suzuki@example.com>\n"
        today = Time.zone.now
        expired_day = Time.zone.now + 7.days.next
        zone = today.strftime("%z")

        setting = SieveFilterSetting.new
        setting.begin_at = today
        setting.end_at = expired_day
        setting.vacation = true
        setting.reply_options = "only-internal"
        setting.subject = subject;
        setting.body = body;

        expected = <<-EOS
require "date";
require "relational";
require "vacation";
if allof (currentdate :value "ge" :zone "#{zone}" "iso8601" "#{today.iso8601}",
          currentdate :value "le" :zone "#{zone}" "iso8601" "#{expired_day.iso8601}") {
  if anyof(address :domain ["from"] ["example.com"],
           address :domain ["from"] ["example.co.jp"],
           address :domain ["from"] ["example.net"]) {
    vacation
      :days 1
      :subject "#{subject}"
      :addresses ["#{my_address}"]
"I'm on a vacation.
I'll return next week.
-- 
\\"Ichiro Suzuki\\" <suzuki@example.com>
";
  }
}
keep;
        EOS
        actual = setting.to_sieve_script(my_address: my_address,
                                         domains: domains)
        assert_equal(expected, actual)
      end

      def test_vacation_reply_to_external
        my_address = "suzuki@example.com";
        domains = ["example.com", "example.co.jp", "example.net"]
        subject = "Vacation"
        body =
          "I'm on a vacation.\n" +
          "I'll return next week.\n" +
          "-- \n" +
          "\"Ichiro Suzuki\" <suzuki@example.com>\n"
        today = Time.zone.now
        expired_day = Time.zone.now + 7.days.next
        zone = today.strftime("%z")

        setting = SieveFilterSetting.new
        setting.begin_at = today
        setting.end_at = expired_day
        setting.vacation = true
        setting.reply_options = "only-external"
        setting.subject = subject;
        setting.body = body;

        expected = <<-EOS
require "date";
require "relational";
require "vacation";
if allof (currentdate :value "ge" :zone "#{zone}" "iso8601" "#{today.iso8601}",
          currentdate :value "le" :zone "#{zone}" "iso8601" "#{expired_day.iso8601}") {
  if not anyof(address :domain ["from"] ["example.com"],
           address :domain ["from"] ["example.co.jp"],
           address :domain ["from"] ["example.net"]) {
    vacation
      :days 1
      :subject "#{subject}"
      :addresses ["#{my_address}"]
"I'm on a vacation.
I'll return next week.
-- 
\\"Ichiro Suzuki\\" <suzuki@example.com>
";
  }
}
keep;
        EOS
        actual = setting.to_sieve_script(my_address: my_address,
                                         domains: domains)
        assert_equal(expected, actual)
      end

      def test_vacation_empty_domains
        my_address = "suzuki@example.com";
        domains = []
        subject = "Vacation"
        body =
          "I'm on a vacation.\n" +
          "I'll return next week.\n" +
          "-- \n" +
          "\"Ichiro Suzuki\" <suzuki@example.com>\n"
        today = Time.zone.now
        expired_day = Time.zone.now + 7.days.next

        setting = SieveFilterSetting.new
        setting.begin_at = today
        setting.end_at = expired_day
        setting.vacation = true
        setting.reply_options = "only-internal"
        setting.subject = subject;
        setting.body = body;

        expected = ""
        actual = setting.to_sieve_script(my_address: my_address,
                                         domains: domains)
        assert_equal(expected, actual)
      end
    end
  end
end
