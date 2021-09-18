desc 'Adds the quotes in motivational_quotes.json to the database'
task :add_quotes_to_db do
  file = File.read('./public/motivation_quotes.json')
  json = JSON.parse(file)
  puts json[50]
end

