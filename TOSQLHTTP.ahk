#Persistent
#SingleInstance, force
SetBatchLines, -1
; AHKhttp configuration
paths := {}
paths["/"] := Func("HelloWorld")
paths["/api/multi-attrs.php"] := Func("handleApi")
paths["404"] := Func("NotFound")
paths["/logo"] := Func("Logo")
server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/mime.types")
server.SetPaths(paths)
server.Serve(8000)
; SQLite configuration
db := new SQLiteDB
DBLoc := "C:\TO_DB\todbmanager-0.3\to.db" ; Change to match the location name of your database as needed
DBAccess := "R" ; Open db Readonly
return

Logo(ByRef req, ByRef res, ByRef server) {
    server.ServeFile(res, A_ScriptDir . "/logo.png")
    res.status := 200
}

NotFound(ByRef req, ByRef res) {
    res.SetBodyText("Page not found")
}

HelloWorld(ByRef req, ByRef res) {
    html := getHTML()
    res.SetBodyText(html)
    res.status := 200
}

getHTML() {
    html := 
    ( 
    "<!doctype html>
    <html lang='en'>
        <head>
            <meta charset='utf-8'>
            <title>Wow!</title>
        </head>
        <body>Hello World</body>
        </html>"
    )
    
    return html
}

handleApi(ByRef req, ByRef res, server) {
    global qstrg, body
    res.headers["Access-Control-Allow-Origin"] := "*"
    qstrg := req.queries["ids"] ; Enumerate the Query String Parameters
    Gosub getsql
    res.status := 200
    res.SetBodyText(body)
}

getsql:
db.OpenDB(DBLoc, DBAccess)
element := 
loop, Parse, qstrg, CSV
{
    sql := "Select * from stats where requester_id = '" . A_LoopField . "';" 
    db.GetTable(sql, Result)
    if (Result.Rows[1, 1])
        element .=  """" . Result.Rows[1, 1] . """" . ":{""name"":" . """" . RegExReplace(Result.Rows[1, 2], "(.*[^\s]).*$","$1") . """" . ",""attrs"":{""comm"":" . """" . Format("{1:0.2f}", Result.Rows[1, 6]) . """" . ",""pay"":" . """" . Format("{1:0.2f}", Result.Rows[1, 5]) . """" . ",""fair"":" . """" . Format("{1:0.2f}", Result.Rows[1, 3]) . """" . ",""fast"":" . """" . Format("{1:0.2f}", Result.Rows[1, 4]) . """" . "},""reviews"":" . Result.Rows[1, 8] . ",""tos_flags"":" . Result.Rows[1, 7] . "},"
    else
        element .=  """" . A_LoopField . """" . ":" . """" . """" . ","
}    
db.CloseDB()
StringTrimRight, element, element, 1 ; remove trailing comma
body := "{" . element . "}" ; jsonify the element

return


#Include %A_ScriptDir%\Class_SQLiteDB.ahk
#Include %A_ScriptDir%\AHKhttp.ahk
#Include <AHKsock>
