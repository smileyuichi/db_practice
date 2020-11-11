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
EOF

choice = gets.chomp.to_i

case choice
when 1
    list_view(client)
end