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

# ── Sample gists ──────────────────────────────────────────
first_article = Article.find_by(title: "Getting Started with Rails")

[
  {
    title: "Hello, Ruby!",
    description: "The classic first program — printing to stdout.",
    code: "puts \"Hello, Ruby!\"\nputs \"Today is: \#{Date.today}\"",
    language: "ruby",
    published: true,
    article: nil
  },
  {
    title: "Array methods",
    description: "Common Array methods every Rubyist should know.",
    code: "numbers = [3, 1, 4, 1, 5, 9, 2, 6]\n\nputs numbers.sort.inspect\nputs numbers.uniq.inspect\nputs numbers.select { |n| n > 3 }.inspect\nputs numbers.map { |n| n * 2 }.inspect\nputs numbers.sum",
    language: "ruby",
    published: true,
    article: first_article
  },
  {
    title: "Hash basics",
    description: "Creating and iterating over a Hash.",
    code: "person = { name: \"Alice\", age: 30, role: \"developer\" }\n\nperson.each do |key, value|\n  puts \"\#{key}: \#{value}\"\nend\n\nputs person[:name].upcase",
    language: "ruby",
    published: true,
    article: first_article
  },
  {
    title: "Fibonacci sequence",
    description: "Generate the first N Fibonacci numbers.",
    code: "def fibonacci(n)\n  sequence = [0, 1]\n  (n - 2).times { sequence << sequence[-1] + sequence[-2] }\n  sequence.first(n)\nend\n\nputs fibonacci(10).inspect",
    language: "ruby",
    published: false,
    article: nil
  }
].each do |attrs|
  article = attrs.delete(:article)
  gist = Gist.find_or_create_by!(title: attrs[:title]) { |g| g.assign_attributes(attrs) }
  gist.update!(article: article) if article && gist.article.nil?
end

puts "Seeded #{Gist.count} gists"
