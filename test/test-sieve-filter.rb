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
