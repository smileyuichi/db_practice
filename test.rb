require 'mysql2'

client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "password", :encoding => "utf8", :database => "testDB")

# p client.methods
results = client.query("SELECT * FROM books")
results.each do |result|
    puts "| #{result["book_id"]} | #{result["title"]} |"
end

# puts <<~eof
# 実行したい操作を選択してください。
# 1.データ一覧を表示
# 2.本の番号で検索する
# eof
# action = gets.chomp.to_i

# case action
# when 1 # 登録データの一覧検索結果
#     results = client.query('select * from books')
#     puts '|番号|   タイトル   | 著者 |  発売日  |カテゴリー| 価格 |在庫|'
#     puts '--------------------------------------------------------------'
#     results.each do |result|
#         puts "| #{result["book_id"]} | #{result["title"]} | #{result["author"]} | #{result["date"]} |  #{result["cat_id"] } | #{result["price"] } | #{result["stock"] } |"
#     end
# when 2 # 本の番号検索
#     puts "本の番号を入力してください"
#     book_id_search = gets.chomp.to_i
#     statement = client.prepare('select * from books where book_id = ?')
#     results = statement.execute(book_id_search)
#     results.each do |row| 
#     puts row # {"id"=>1, "dep"=>1, "name"=>"hoge"}
#     end
# else
#     puts "error:入力値が不正です"
# end
