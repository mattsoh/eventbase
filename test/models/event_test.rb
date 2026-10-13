require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "valid with title and starts_at" do
    assert Event.new(title: "Meetup", starts_at: 1.day.from_now).valid?
  end

  test "requires title and starts_at" do
    event = Event.new
    assert_not event.valid?
    assert event.errors.of_kind?(:title, :blank)
    assert event.errors.of_kind?(:starts_at, :blank)
  end

  test "ends_at must be after starts_at" do
    start = 1.day.from_now
    assert_not Event.new(title: "Meetup", starts_at: start, ends_at: start).valid?
    assert_not Event.new(title: "Meetup", starts_at: start, ends_at: start - 1.hour).valid?
    assert Event.new(title: "Meetup", starts_at: start, ends_at: start + 1.hour).valid?
  end

  test "virtual defaults to false" do
    assert_equal false, Event.new.virtual
  end

  test "upcoming returns future events soonest first" do
    assert_equal [ events(:upcoming_soon), events(:upcoming_later) ], Event.upcoming.to_a
  end

  test "past returns past events most recent first" do
    assert_equal [ events(:past) ], Event.past.to_a
  end
end
