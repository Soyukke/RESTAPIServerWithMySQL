include("struct.jl")
include("db.jl")
include("restapi.jl")

function main()
    conn = init_mysql()
    # insert(conn, TestStruct("aab", 30))
    # @show getTest(conn, "aab")
    # conn = init_mysql()
    serve(conn)
end

main()