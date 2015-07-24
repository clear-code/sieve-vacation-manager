require "sieve-vacation-manager/app"
require "sieve-vacation-manager/version"
require "json"
require "date"
require "test/unit/capybara"

module SieveVacationManager
  class TestApp < Test::Unit::TestCase
    include Capybara::DSL

    def setup
      Capybara.app = App.new
      DatabaseCleaner.start
    end

    def teardown
      DatabaseCleaner.clean
    end

    class TestHTML < self
      def test_index
        visit "/"
        displayed_text = page.first("a.navbar-brand").text
        expected = "Out of Office Auto-Reply"
        assert_equal(expected, displayed_text)
      end
    end

    class TestLoginLogout < self
      def setup
        visit "/login"
        fill_in "email", with: "alice@example.com"
        fill_in "password", with: "test"
        find(".form-signin button").click
      end

      def test_login
        redirected_path = "/"
        within(".navbar-collapse") do
          assert_equal("alice@example.com", find("a.user-email").text)
        end
        assert_equal(redirected_path, page.current_path)
      end

      def test_logout
        visit "/"
        within(".navbar-collapse") do
          find(".btn-logout").click
        end
        redirected_path = "/login"
        assert_equal(redirected_path, page.current_path)
      end
    end

    class TestSieveFilterSetting < self
      def setup
        visit "/login"
        fill_in "email", with: "alice@example.com"
        fill_in "password", with: "test"
        find(".form-signin button").click
      end

      sub_test_case "placeholder existence" do
        test "display mail subject placeholder" do
          within("div.vacation-settings") do
            expected = "(your name) is out of office."
            assert_equal("#{expected}", find("input.mail-subject")["placeholder"])
          end
        end

        test "display mail body placeholder" do
          within("div.vacation-settings") do
            expected = "I will be back in office on 2015-06-01 and reply to your e-mail."
            assert_equal("#{expected}", find("textarea.mail-body")["placeholder"])
          end
        end

        test "display forwaring address placeholder" do
          within("div.forwarding-email") do
            expected = "alice@example.com"
            assert_equal("#{expected}",
                         find("input.forwarding-address")["placeholder"])
          end
        end
      end

      sub_test_case "register sieve filter" do
        sub_test_case "save success" do
          test "vacation settings" do
            today = Time.zone.now
            expired_day = Time.zone.now + 7.days.next
            fill_in "datetime-begin", with: today
            fill_in "datetime-end", with: expired_day
            check "toggle-vacation"
            find("input[name='reply-options'][value='only-internal']").set(true)
            fill_in "mail-subject", with: "test subject"
            fill_in "mail-body", with: "It's mail body"
            find(".apply-btn").click
            assert_equal("/vacation-config", page.current_path)
            within("div.sieve-setting") do
              expected = (expired_day + 1.day).strftime("%Y/%m/%d")
              assert_equal("#{expected}", find("p.datetime-end").text)
            end
          end

          test "vacation and forwarding settings" do
            today = Time.zone.now
            expired_day = Time.zone.now + 7.days.next
            forwarding_address = "bob@example.com"
            fill_in "datetime-begin", with: today
            fill_in "datetime-end", with: expired_day
            check "toggle-vacation"
            find("input[name='reply-options'][value='all']").set(true)
            fill_in "mail-subject", with: "test subject"
            fill_in "mail-body", with: "It's mail body"
            check "toggle-forward"
            fill_in "forwarding-address", with: forwarding_address
            find(".apply-btn").click
            assert_equal("/vacation-config", page.current_path)
            within("div.sieve-setting") do
              assert_equal("#{forwarding_address}", find("p.forwarding-address").text)
            end
          end
        end

        sub_test_case "save failure" do
          test "already expired" do
            today = Time.zone.now
            expired_day = Time.zone.now - 7.days
            fill_in "datetime-begin", with: today
            fill_in "datetime-end", with: expired_day
            check "toggle-vacation"
            find("input[name='reply-options'][value='only-internal']").set(true)
            fill_in "mail-subject", with: "test subject"
            fill_in "mail-body", with: "It's mail body"
            find(".apply-btn").click
            assert_equal("/vacation-config", page.current_path)
          end

          test "excess deadline" do
            today = Time.zone.now + 7.days
            expired_day = Time.zone.now
            fill_in "datetime-begin", with: today
            fill_in "datetime-end", with: expired_day
            check "toggle-vacation"
            find("input[name='reply-options'][value='only-internal']").set(true)
            fill_in "mail-subject", with: "test subject"
            fill_in "mail-body", with: "It's mail body"
            find(".apply-btn").click
            assert_equal("/vacation-config", page.current_path)
          end

          test "specify one's own address" do
            today = Time.zone.now
            expired_day = Time.zone.now + 7.days
            forwarding_address = "alice@example.com"
            check "toggle-forward"
            fill_in "forwarding-address", with: forwarding_address
            find(".apply-btn").click
            assert_equal("/vacation-config", page.current_path)
          end
        end
      end
    end
  end
end
