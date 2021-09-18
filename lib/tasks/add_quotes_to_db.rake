desc 'Adds the quotes in motivational_quotes.json to the database'
task :add_quotes_to_db => :environment do
  file = File.read('./public/motivation_quotes.json')
  json = JSON.parse(file)

  for quote in json
    Quote.create(
      quote_text: quote["text"],
      author: quote["author"] 
    )
  end
end

