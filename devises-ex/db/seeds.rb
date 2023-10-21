# db/seeds.rb

# Clear existing data
Author.destroy_all
Book.destroy_all

# Create some authors. Since Devise is being used, passwords are required and should be handled appropriately.
authors = 10.times.map do |i|
  Author.create!(
    name: "Author #{i + 1}",
    email: "author#{i + 1}@example.com",
    password: 'password123', # Consider using a more secure password in production.
    password_confirmation: 'password123'
  )
end

# Create some books, each associated with an author.
50.times do |i|
  Book.create!(
    name: "Book #{i + 1}",
    release_date: Date.today - rand(1..365)*i, # Randomly generates release dates within the past i years.
    author: authors.sample # Randomly assigns one of the previously created authors.
  )
end

puts "Created #{Author.count} authors"
puts "Created #{Book.count} books"
