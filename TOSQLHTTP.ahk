#NoEnv
#Persistent
#SingleInstance, force


SetBatchLines, -1
ListLines Off


; AHKhttp configuration
paths := {}
paths["/"] := Func("HelloWorld")
paths["/api/multi-attrs.php"] := Func("handleApi")
paths["404"] := Func("NotFound")


server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/mime.types")
server.SetPaths(paths)
server.Serve(8000)


; SQLite configuration
db := new SQLiteDB
DBLoc := "C:\TO_DB\todbmanager-master\to.db" ; Change to match the location name of your database as needed
DBAccess := "R" ; Open db Readonly



Menu, Tray, Add , Kill HTTP and Exit, KillHTTP
return


NotFound(ByRef req, ByRef res) {
    res.SetBody("Page not found")
}

HelloWorld(ByRef req, ByRef res) {
    html := getHTML()
    res.SetBody(html)
    res.status := 200 . " OK"
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
    res.headers["Content-Type"] := "text/html; charset=utf-8"
    qstrg := req.queries["ids"] ; Enumerate the Query String Parameters
    sqlstr := getsql(qstrg)
    res.SetBody(sqlstr)
    res.status := 200 . " OK"
}

getsql(qstrg) {
    global db, DBLoc, DBAccess
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
    element := SubStr(element, 1, -1)
    sqlstr := "{" . element . "}" ; jsonify the element
    
    return sqlstr
}

class Uri
{
    Decode(str) {
        Loop
            If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
                StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
            Else Break
        Return, str
    }

    Encode(str) {
        f = %A_FormatInteger%
        SetFormat, Integer, Hex
        If RegExMatch(str, "^\w+:/{0,2}", pr)
            StringTrimLeft, str, str, StrLen(pr)
        StringReplace, str, str, `%, `%25, All
        Loop
            If RegExMatch(str, "i)[^\w\.~%]", char)
                StringReplace, str, str, %char%, % "%" . Asc(char), All
            Else Break
        SetFormat, Integer, %f%
        Return, pr . str
    }
}

class HttpServer
{
    static servers := {}
    

    LoadMimes(file) {
        if (!FileExist(file))
            return false

        FileRead, data, % file
        types := StrSplit(data, "`n")
        this.mimes := {}
        for i, data in types {
            info := StrSplit(data, " ")
            type := info.RemoveAt(1)
            ; Seperates type of content and file types
            info := StrSplit(LTrim(SubStr(data, StrLen(type) + 1)), " ")

            for i, ext in info {
                this.mimes[ext] := type
            }
        }
        return true
    }

    GetMimeType(file) {
        default := "text/plain"
        if (!this.mimes)
            return default

        SplitPath, file,,, ext
        type := this.mimes[ext]
        if (!type)
            return default
        return type
    }

    
    SetPaths(paths) {
        this.paths := paths
    }

    Handle(ByRef request) {
        response := new HttpResponse()
        if (!this.paths[request.path]) {
            func := this.paths["404"]
            response.status := 404
            if (func)
                func.(request, response, this)
            return response
        } else {
            this.paths[request.path].(request, response, this)
        }
        return response
    }

    Serve(port) {
        this.port := port
        HttpServer.servers[port] := this
        AHKsock_Listen(port, "HttpHandler")
        OutputDebug, % "AHKsock_Listen...." AHKsock_Listen(port, "()")       
               
        AHKsock_ErrorHandler("AHKsockErrors")
        OutputDebug, % "AHKsock_ErrorHandler...." AHKsock_ErrorHandler("""")
        
    }
    
}

HttpHandler(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, bDataLength = 0) {
    static sockets := {}
    
    
    
    if (!sockets[iSocket]) {
        sockets[iSocket] := new Socket(iSocket)
        ;SockOptions go here
        AHKsock_SockOpt(iSocket, "TCP_NODELAY", True)
        AHKsock_SockOpt(iSocket, "SO_KEEPALIVE", True)
    }
    socket := sockets[iSocket]
    
     
    
    if (sEvent == "ACCEPTED") {
        ;socket.Close()
    } else if (sEvent == "DISCONNECTED") {
        socket.request := false
        sockets[iSocket] := false
        socket.Stop()
    } else if (sEvent == "SEND" || sEvent == "SENDLAST" ) {
        if (socket.TrySend()) {
            ;OutputDebug, % "*Success! Data Sent from sEvent [" sEvent "] on Socket [" iSocket "]"
        }
    } else if (sEvent == "RECEIVED") {
        
        server := HttpServer.servers[sPort]

        text := StrGet(&bData, "UTF-8")
        request := new HttpRequest(text)
        response := server.Handle(request)
        
        if (socket.TrySend(response.Generate())) {
            ;OutputDebug, % "**Success! Data Sent from sEvent [" sEvent "] on Socket [" iSocket "]"
        }   
    }
}

class HttpRequest
{
    __New(data = "") {
        if (data)
            this.Parse(data)
    }

    GetPathInfo(top) {
        results := []
        while (pos := InStr(top, " ")) {
            results.Insert(SubStr(top, 1, pos - 1))
            top := SubStr(top, pos + 1)
        }
        this.method := results[1]
        this.path := Uri.Decode(results[2])
        this.protocol := top
    }

    GetQuery() {
        pos := InStr(this.path, "?")
        query := StrSplit(SubStr(this.path, pos + 1), "&")
        if (pos)
            this.path := SubStr(this.path, 1, pos - 1)

        this.queries := {}
        for i, value in query {
            pos := InStr(value, "=")
            key := SubStr(value, 1, pos - 1)
            val := SubStr(value, pos + 1)
            this.queries[key] := val
        }
    }

    Parse(data) {
        this.raw := data
        data := StrSplit(data, "`n`r")
        headers := StrSplit(data[1], "`n")
        this.body := LTrim(data[2], "`n")

        this.GetPathInfo(headers.RemoveAt(1))
        this.GetQuery()
        this.headers := {}

        for i, line in headers {
            pos := InStr(line, ":")
            key := SubStr(line, 1, pos - 1)
            val := Trim(SubStr(line, pos + 1), "`n`r ")

            this.headers[key] := val
        }
    }
}

class HttpResponse
{
    __New() {
        this.headers := {}
        this.status := 0
        this.protocol := "HTTP/1.1"
        
        
        this.SetBody("")
        
    }

    Generate() {
        FormatTime, date, A_NowUTC, ddd, d MMM yyyy HH:mm:ss
        this.headers["Date"] := date . " GMT"
        this.headers["Access-Control-Allow-Origin"] := "*"
        this.headers["Connection"] := "Keep-Alive, 20"
        this.headers["Access-Control-Max-Age"] := "120"
        

        response := this.protocol . " " . this.status . "`r`n"
        for key, value in this.headers {
            response := response . key . ": " . value . "`r`n"
        }
        response := response . "`r`n" . this.body 
        return response
    }

    SetBody(body) {
        ;Determine Content-Length header of body, -1 removes the null character
        this.headers["Content-Length"] := StrPutVar(body, var, "UTF-8") - 1 
        this.body := body
    }
}

class Socket
{
    __New(socket) {
        this.socket := socket
        this.interval := -20000
        this.timer := ObjBindMethod(this, "Stop")
    }
    
    
    Stop() {
        ;This OutputDebug is used to CLOSE the socket
        OutputDebug, % "Closed socket [" this.socket "]  returned message is [" AHKsock_Close(this.socket) "] and ErrorLevel [" ErrorLevel "]"
    }

     
   Close() {
        timer := this.timer
        SetTimer % timer, % this.interval
    }

    TrySend(data = "") {
        if (data != "")
            this.data := data
        
        if (!this.data || this.data == "")
            return false
        
        ;length of data to send, -1 removes the null character        
        length := StrPutVar(this.data, outData, "UTF-8") - 1
        
        this.dataSent := 0
        loop {
            if ((i := AHKsock_Send(this.socket, &outData, length - this.dataSent)) < 0) {
                ;Check if we received WSAEWOULDBLOCK errors
                if (i == -2 || i== -5) {
                    return  ;We'll keep sending data the next time we get the SEND event
                } else { ;Something bad has happened
                    OutputDebug, % "Something bad has happened - AHKsock_Send failed with return value = " i " and ErrorLevel = [" ErrorLevel "] !"
                    OutputDebug, % "Socket [" this.socket "] AHKsock_Close Error [" AHKsock_Close(this.socket) "] ErrorLevel [" ErrorLevel "]"
                    return 
                }
            }
            if (i < length - this.dataSent) {
                this.dataSent += i
            } else {
                ;We're done sending data so break out of the loop
                break
            }
        }
        
        this.dataSent := 0
        this.data := ""
        return true
    }
}


;Collect any winsock errors
AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket "." : ".") 
}

;Used instead of StrLen function. Could be added to library
StrPutVar(string, ByRef var, encoding)
{
    ; Ensure capacity.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut returns char count, but VarSetCapacity needs bytes.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; Copy or convert the string.
    return StrPut(string, &var, encoding)
}

#Include %A_ScriptDir%\Class_SQLiteDB.ahk
#Include <AHKsock>



KillHTTP:
; Closedown all winsock sockets and exit the app
AHKsock_Close()
ExitApp
Return
