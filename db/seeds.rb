# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample articles for the CMS
[
  {
    title: "Welcome to our CMS",
    content: "This is a basic Ruby on Rails CMS built with scaffolding. You can create, read, update, and delete articles.",
    author: "Admin",
    published: true
  },
  {
    title: "Getting Started with Rails",
    content: "Ruby on Rails is a server-side web application framework written in Ruby. It follows the Model-View-Controller (MVC) pattern.",
    author: "John Doe",
    published: true
  },
  {
    title: "Draft Article",
    content: "This is a draft article that hasn't been published yet.",
    author: "Jane Smith",
    published: false
  }
].each do |attrs|
  Article.find_or_create_by!(title: attrs[:title]) { |a| a.assign_attributes(attrs) }
end

puts "Seeded #{Article.count} articles"
