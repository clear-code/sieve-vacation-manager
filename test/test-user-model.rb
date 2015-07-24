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
