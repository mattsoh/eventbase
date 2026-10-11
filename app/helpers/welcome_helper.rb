# Content for the public welcome page.
#
# PLACEHOLDER CONTENT: every string is "Placeholder text" until real copy is
# written. The counts below only control how many items each section shows.
module WelcomeHelper
  ACCENTS = %w[crimson rust forest].freeze

  TICKER_COUNT = 5
  FEATURE_COUNT = 3
  ROW_COUNT = 4
  EVENT_COUNT = 3
  MANIFESTO_COUNT = 4
  FOOTER_COLUMN_COUNT = 3

  # Rotates crimson -> rust -> forest across peer items (DESIGN.MD "Rotating accents").
  def accent_for(index)
    ACCENTS[index % ACCENTS.size]
  end
end
