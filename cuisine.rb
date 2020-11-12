require 'mysql2'

# データベースに接続(ホスト名、ユーザー名、パスワード、エンコード、データベースを指定する)
client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "password", :encoding => "utf8", :database => "healthDB")

# 料理テーブルを一覧表示する
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

# 入力されたcat_idとcuisine_catテーブルに存在する番号を照合する。
# 値が不正なら再入力させる
def input_cuisine_cat(get_cuisine_cat,test)
    if test.include?(get_cuisine_cat)
    else
        puts "エラー：正しい値を入力して下さい"
        get_cuisine_cat = gets.chomp.to_i
        input_cuisine_cat(get_cuisine_cat,test)
    end
end

def create_new_cuisine(client)
    puts "料理名は？"
    cuisine_name = gets.chomp
    puts "使用食材を入力して下さい"

    # 使用食材管理番号を配列に格納
    food_ids = []

    puts "'.'を入力すると入力処理を終わります"

    # デリミターの設定
    end_key = "."
    
    # 食材名を配列food_namesに入れていく処理
    food_name = gets.chomp
    while end_key != food_name
        # 食材テーブルに使用食材があるかテーブル確認
        foods = client.query("select id from food where name = '#{food_name}'")
        # 検索結果のカウントがあれば食材のIDを配列に格納する、なければエラー文とデータ破棄
        if foods.count != 0
            foods.each do |food_id|
                food_ids << food_id["id"]
            end
        else
            puts "食材テーブルにデータがありません。"    
        end
        food_name = gets.chomp
    end
    test = []
    puts "料理ジャンルを選択して下さい"
    cuisine_cats = client.query("select id,name from cuisine_cat")
    cuisine_cats.each do |cat|
        puts "#{cat["id"]}. #{cat["name"]}"
        test << cat["id"]
    end

    get_cuisine_cat = gets.chomp.to_i
    # cuisine_catテーブルと入力値を照合する関数を呼び出す
    input_cuisine_cat(get_cuisine_cat, test)
    puts <<~EOF
    情報を保存しますか？
    1.保存する
    2.中止する
    EOF
    decition_flag = false
    while !decition_flag
        decition = gets.chomp.to_i
        if decition == 1
            # cuisine_name:料理名、food_ids:使用する食材の番号、get_cuisine_cat:料理のカテゴリー番号
            # cuisineテーブルに料理名と料理カテゴリーを入れる
            # cuisineテーブルに料理が登録されたら、管理番号を検索してcuisine_idに格納
            # using_foodテーブルにcuisine_idとfood_idを格納して料理と使用した食材を紐付ける
            client.query("insert into cuisine (name,cat_id) value ('#{cuisine_name}', #{get_cuisine_cat})")
            cuisine_id = client.query("select id from cuisine where name = '#{cuisine_name}'")
            cuisine_id.each do |cuisine|
                food_ids.each do |food_id|
                    client.query("insert into using_food(cuisine_id,food_id) values(#{cuisine["id"]},#{food_id})")
                end
            end
            decition_flag = true
            puts "料理の登録が無事完了しました。"
        elsif decition == 2
            puts "料理の登録を中止しました。"
            decition_flag = true
            return
        else
            puts "エラー：正しい値を入力して下さい"
        end
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
    create_new_cuisine(client)
end