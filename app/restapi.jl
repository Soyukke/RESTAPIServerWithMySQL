using HTTP
import HTTP:bytes
using JSON
using JSON2

const localhost = "0.0.0.0"
const port = parse(Int, ENV["PORT"])
println("ポート番号: ", port)
const headers = ["Content-Type" => "application/json"]

# apitest/nameのname部分とTestStructを紐づけ，uniqueなnameを持つ
test_structs = Dict{String, TestStruct}()

"""
辞書型をJSON文字列に変換する
"""
function dict2json_str(json_dict::AbstractDict)
    buf = IOBuffer()
    JSON.print(buf, json_dict, 4)
    return json_str = String(take!(buf))
end

"""
POSTされたJSONを保存する
"""
function postTest(conn::DBInterface.Connection, req::HTTP.Request)::HTTP.Response
    println("createTest")
    request_body = String(HTTP.payload(req))
    try
        # String を parseして　TestStruct型変数作成
        test_struct = JSON2.read(request_body, TestStruct)
        insert(conn, test_struct)
        return HTTP.Response(200)
    catch e
        body = """
        {
            "message": "$(e.msg)"
        }
        """
        return HTTP.Response(500, body=bytes(body))
    end
end

"""
GET，nameをpathから取得して，そのnameを持つデータをJSONで返す
"""
function getTest(conn::DBInterface.Connection, req::HTTP.Request)::HTTP.Response
    println("getTest")
    try
        uri = HTTP.URI(req.target)
        params = HTTP.queryparams(uri)
        # testapi/name, get name
        name = HTTP.URIs.splitpath(uri.path)[2]
        test_struct::TestStruct = getTest(conn, name)
        json_str = JSON2.write(test_struct)
        json_dict = JSON2.read(json_str, Dict)
        json_str = dict2json_str(json_dict)
        return HTTP.Response(200, headers, body = bytes(json_str))
    catch
        body = """
        {
            "message": "No data"
        }
        """
        return HTTP.Response(404, headers, body = bytes(body))
    end
end

"""
PUT データを作成 or 更新する
nameを取得して，その他の値はbodyから取得する
あとはpostと同じ，request.bodyに"name":nameを追加してpostTestに投げる
"""
function putTest(conn::DBInterface.Connection, req::HTTP.Request)::HTTP.Response
    println("putTest")
    try
        uri = HTTP.URI(req.target)
        params = HTTP.queryparams(uri)
        # testapi/name, get name
        name = HTTP.URIs.splitpath(uri.path)[2]
        test_struct0 = JSON2.read(String(req.body), TestStruct)
        println("before test_struct")
        # pathでnameを書き換える
        test_struct = TestStruct(name, test_struct0.number)
        println("before upsert")
        upsert(conn, test_struct)
        return HTTP.Response(200)
    catch
        body = """
        {
            "message": "No data"
        }
        """
        return HTTP.Response(404, headers, body = bytes(body))
    end
end

"""
DELETE データを削除する
pathからnameを取得して，そのnameを持つstructを削除する
"""
function deleteTest(conn::DBInterface.Connection, req::HTTP.Request)::HTTP.Response
    println("deleteTest")
    try
        uri = HTTP.URI(req.target)
        params = HTTP.queryparams(uri)
        # testapi/name, get name
        name = HTTP.URIs.splitpath(uri.path)[2]
        # delete
        delete(conn, name)
        println("deleted")
        return HTTP.Response(200)
    catch
        body = """
        {
            "message": "No data"
        }
        """
        return HTTP.Response(404, headers, body = bytes(body))
    end
end

"""
APIサーバ起動
"""
function serve(conn::DBInterface.Connection)
    TEST_ROUTER = HTTP.Router()
    HTTP.@register(TEST_ROUTER, "POST", "/testapi", req::HTTP.Request -> postTest(conn, req))
    HTTP.@register(TEST_ROUTER, "GET", "/testapi/*", req::HTTP.Request -> getTest(conn, req))
    HTTP.@register(TEST_ROUTER, "PUT", "/testapi/*", req::HTTP.Request -> putTest(conn, req))
    HTTP.@register(TEST_ROUTER, "DELETE", "/testapi/*", req::HTTP.Request -> deleteTest(conn, req))
    println("listen...")
    HTTP.serve(TEST_ROUTER, localhost, port)
end