require 'mysql2'

# データベースに接続(ホスト名、ユーザー名、パスワード、エンコード、データベースを指定する)
client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "password", :encoding => "utf8", :database => "healthDB")

# 料理テーブルを一覧表示する
def list_view(client)
    categories = client.query("select id ,name from cuisine_cat")
    cuisines = client.query("select name,cat_id from cuisine")
    puts <<~EOF
    登録されている料理の一覧
    --------------------
    EOF

    # ”select B.name, A.name from cuisine A RIGHT JOIN cuisine_cat B on A.cat_id = B.id”を表現
    categories.each do |cat|
        cuisines.each do |cuisine|
            if cat["id"] == cuisine["cat_id"]
                puts "#{cat["name"]} | #{cuisine["name"]}"
            end
        end
    end
end

# 入力されたcat_idと料理カテゴリーのIDを照合する。
# 値が不正なら再入力させる
def input_cuisine_cat(get_cuisine_cat,cuisine_cat_ids)
    if cuisine_cat_ids.include?(get_cuisine_cat)
    else
        puts "エラー：正しい値を入力して下さい"
        get_cuisine_cat = gets.chomp.to_i
        input_cuisine_cat(get_cuisine_cat,cuisine_cat_ids)
    end
end

# 料理の新規登録
def create_new_cuisine(client)
    puts "料理名は？"
    cuisine_name = gets.chomp
    puts "使用食材を入力して下さい"

    # 使用食材管理番号を配列に格納
    food_ids = []

    puts "'.'を入力すると入力処理を終わります"

    # エンドキーの設定
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
    # 料理カテゴリーのidを格納するための配列
    cuisine_cat_ids = []
    puts "料理ジャンルを選択して下さい"
    cuisine_cats = client.query("select id,name from cuisine_cat")
    cuisine_cats.each do |cat|
        puts "#{cat["id"]}. #{cat["name"]}"
        cuisine_cat_ids << cat["id"]
    end

    get_cuisine_cat = gets.chomp.to_i
    # cuisine_catテーブルと入力値を照合する関数を呼び出す
    input_cuisine_cat(get_cuisine_cat, cuisine_cat_ids)
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

# 料理に必要な食材の情報を表示する
def cuisine_detail(client)
    puts "食材を知りたい料理の名前を入れて下さい"
    target_cuisine_name_frag = false
    while target_cuisine_name_frag == false
        # 詳細を知りたい料理名を入力
        target_cuisine_name = gets.chomp
        # 料理の管理番号を格納するための変数
        cuisine_id = nil
        # 詳細を知りたい料理名で検索し、cuisineテーブル内の名前とIDを取り出す
        get_cuisine = client.query("select name, id from cuisine where name = '#{target_cuisine_name}'")
        if get_cuisine.count != 0
            get_cuisine.each do |name|
                puts <<~EOF
                #{name["name"]}
                -----------
                EOF
                cuisine_id = name["id"]
            end
            target_cuisine_name_frag = true
        else
            puts <<~EOF
            エラー：該当する料理名がありません
            食材を知りたい料理の名前を入れて下さい
            EOF
        end
    end
    # 料理に対して使用している食材の管理番号を格納するための配列
    using_food_id = []
    # 料理のIDで検索してusing_foodテーブルから食材のIDを取り出す
    client.query("select food_id from using_food where cuisine_id = '#{cuisine_id}'").each do |cuisine_id|
        using_food_id << cuisine_id["food_id"]
    end
    # 配列using_food_idを用いてfoodテーブルを検索、foodの名前を取り出す
    using_food_id.each do |id|
        client.query("select name from food where id = #{id}").each do |food|
            puts food["name"]
        end
    end
end

def cuisine_delete(client)
    puts "削除したい料理名を入力して下さい"
    delete_id = nil
    delete_cuisine_frag = false
    while !delete_cuisine_frag
        # 削除したい料理名を入力
        delete_cuisine_name = gets.chomp
        # 削除したい料理のレコードを検索
        cuisine = client.query("select id, name from cuisine where name = '#{delete_cuisine_name}'")
        if cuisine.count != 0
            cuisine.each do |cuisine|
                delete_id = cuisine["id"]
            end
            # 料理と食材を紐付けている中間テーブルの削除
            client.query("delete from using_food where cuisine_id = #{delete_id}")
            # cuisineテーブルの対象レコードを削除
            client.query("delete from cuisine where id = #{delete_id}")
            delete_cuisine_frag = true
            puts "料理の削除が完了しました"
        else
            puts "エラー：該当する料理がありません"
        end
    end
    
end

puts <<~EOF
実行したい処理を選択して下さい。
--------------------------
1.料理を一覧表示する
2.新しい料理を追加する
3.料理に必要な食材を表示する
4.料理を削除する
EOF

choice = gets.chomp.to_i

case choice
when 1
    list_view(client)
when 2
    create_new_cuisine(client)
when 3
    cuisine_detail(client)
when 4
    cuisine_delete(client)
end