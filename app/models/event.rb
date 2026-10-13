class Event < ApplicationRecord
  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }
  scope :past, -> { where(starts_at: ...Time.current).order(starts_at: :desc) }

  validates :title, presence: true
  validates :starts_at, presence: true
  validate :ends_after_start

  private

  def ends_after_start
    return if ends_at.blank? || starts_at.blank?

    errors.add(:ends_at, "must be after the start time") if ends_at <= starts_at
  end
end
