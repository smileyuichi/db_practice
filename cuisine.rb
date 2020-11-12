require 'mysql2'

# データベースに接続(ホスト名、ユーザー名、パスワード、エンコード、データベースを指定する)
client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "password", :encoding => "utf8", :database => "healthDB")

def list_view(client)
    results = client.query("SELECT * FROM cuisine")
    puts <<~EOF
    登録されている料理の一覧
    --------------------
    EOF

    results.each do |result|
        puts result["name"]
    end
end

puts <<~EOF
実行したい処理を選択して下さい。
--------------------------
1.料理を一覧表示する
2.新しい料理を追加する
EOF

choice = gets.chomp.to_i

case choice
when 1
    list_view(client)
when 2
    puts "料理名は？"
    cuisine_name = gets.chomp
    puts "使用食材は？"
    client.query("select name from food").each do |food|
        puts food["name"]
    end
    # 使用食材を配列に格納
    food_names = []
    # デリミターの設定
    end_key = "."
    # 食材名を配列food_namesに入れていく処理
    food_name = gets.chomp
    while end_key != food_name
        # 食材テーブルに使用食材があるか確認、なければ入力を破棄
        answers = client.query("select name from food where name = '#{food_name}'")
        if answers.count != 0
            answers.each do |ans|
                food_names << food_name
            end
        else
            puts "食材テーブルにデータがありません。"    
        end
        food_name = gets.chomp
    end
    
    p food_names
    # p results = client.query("insert into cuisine(name,cat_id) values('#{cuisine_name}',1)")
    # p client.affected_rows
    puts "登録が完了しました。"
end