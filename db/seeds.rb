# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Sample events, relative to today so there are always some upcoming ones.
# Keyed by title so re-running the seeds doesn't create duplicates.
today = Time.current.beginning_of_day

[
  { title: "Rails Study Group", days: 3, hour: 18, length: 2, location: "Online", virtual: true,
    description: "Weekly session working through the Rails guides together. Bring questions." },
  { title: "Board Game Night", days: 5, hour: 19, length: 3, location: "The Draughts Café, London", virtual: false,
    description: "Casual games night. Beginners welcome, plenty of games provided." },
  { title: "Intro to Hotwire", days: 8, hour: 17, length: 1, location: "Online", virtual: true,
    description: "A short talk on Turbo and Stimulus, followed by Q&A." },
  { title: "Park Run Meetup", days: 10, hour: 9, length: 1, location: "Hyde Park, London", virtual: false,
    description: "5k at your own pace, coffee afterwards." },
  { title: "Design Critique Session", days: 14, hour: 18, length: 2, location: "Online", virtual: true,
    description: "Share something you're working on and get friendly feedback." },
  { title: "Hackathon Weekend", days: 21, hour: 10, length: 8, location: "Imperial College, London", virtual: false,
    description: "Build something in a weekend. Teams of up to four." },
  { title: "Photography Walk", days: 28, hour: 14, length: 3, location: "South Bank, London", virtual: false,
    description: "Explore the river with other photographers. Any camera is fine." },
  { title: "Open Source Sprint", days: 35, hour: 11, length: 5, location: "Online", virtual: true,
    description: "Pick an issue and make your first contribution, with mentors on hand." },
  { title: "Welcome Social", days: -7, hour: 19, length: 2, location: "Student Union Bar", virtual: false,
    description: "Kick-off social for new members." },
  { title: "Git Basics Workshop", days: -3, hour: 17, length: 2, location: "Online", virtual: true,
    description: "Branches, commits and pull requests from scratch." }
].each do |attrs|
  starts_at = today + attrs[:days].days + attrs[:hour].hours

  Event.find_or_create_by!(title: attrs[:title]) do |event|
    event.description = attrs[:description]
    event.starts_at = starts_at
    event.ends_at = starts_at + attrs[:length].hours
    event.location = attrs[:location]
    event.virtual = attrs[:virtual]
  end
end
