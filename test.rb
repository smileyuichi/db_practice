require 'mysql2'

client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "password", :encoding => "utf8", :database => "testDB")

results = client.query('select * from books')
results.each do |result|
    puts result
end
