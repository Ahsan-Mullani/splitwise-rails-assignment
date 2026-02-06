puts "Seeding users..."

User.find_or_create_by!(email: "admin@example.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
end

5.times do |i|
  User.find_or_create_by!(email: "user#{i+1}@example.com") do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
  end
end

puts "Users seeded successfully"
