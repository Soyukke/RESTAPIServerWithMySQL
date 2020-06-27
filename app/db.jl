using MySQL
using DataFrames

const mysql_user = "root"
const mysql_pass = "root"
const mysql_db = "test"
const mysql_port = 3306
const mysql_table = "table1"

"""
MySQLサーバへ接続する
"""
function init_mysql()
    while true
        try
            conn = DBInterface.connect(MySQL.Connection, "db", mysql_user, mysql_pass, port=mysql_port, db=mysql_db)
            # テーブル作成
            try
                result = DBInterface.execute(conn, "CREATE TABLE $(mysql_db).$(mysql_table) (id INT, name VARCHAR(50) NOT NULL UNIQUE)")  
            catch e
                if isa(e, MySQL.API.Error) print(e.msg) end
            return conn
            end
        catch
        end
        println("wait for MySQL...")
        sleep(5)
    end
end

"""
テーブル作成
"""
function create_table(conn::DBInterface.Connection, table::AbstractString)
end

"""
dbに挿入
"""
function insert(conn::MySQL.Connection, x::TestStruct)
    DBInterface.execute(conn, "INSERT INTO $(mysql_table) VALUES ($(x.number), '$(x.name)')")
end

"""
dbに挿入・更新
"""
function upsert(conn::MySQL.Connection, x::TestStruct)
    DBInterface.execute(conn,
    """
    INSERT INTO $(mysql_table) (id, name)
    VALUES
        ($(x.number), '$(x.name)')
    ON DUPLICATE KEY UPDATE
        id = '$(x.name)'
    """
    )
end

"""
dbから削除
"""
function delete(conn::MySQL.Connection, name::String)
    DBInterface.execute(conn, "DELETE FROM $(mysql_table) WHERE name LIKE '$(name)'")
end

"""
テーブルからデータを取得する
"""
function getTest(conn::MySQL.Connection, name::String)
    result = DBInterface.execute(conn, "SELECT * FROM $(mysql_table) WHERE name LIKE '$(name)'")
    df = first(DataFrame(result))
    return TestStruct(df.name, df.id)
end