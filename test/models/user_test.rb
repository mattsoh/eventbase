require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid with email and username" do
    assert User.new(email: "new@example.com", username: "new_user").valid?
  end

  test "requires email and username" do
    user = User.new
    assert_not user.valid?
    assert user.errors.of_kind?(:email, :blank)
    assert user.errors.of_kind?(:username, :blank)
  end

  test "normalizes email" do
    assert_equal "mixed@example.com", User.new(email: "  Mixed@Example.COM ").email
  end

  test "email and username are unique case-insensitively" do
    user = User.new(email: "ONE@example.com", username: "USER_ONE")
    assert_not user.valid?
    assert user.errors.of_kind?(:email, :taken)
    assert user.errors.of_kind?(:username, :taken)
  end

  test "rejects invalid username characters" do
    assert_not User.new(email: "x@example.com", username: "bad name!").valid?
  end
end
