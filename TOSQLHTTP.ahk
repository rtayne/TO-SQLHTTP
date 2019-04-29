#NoEnv
#Persistent
#SingleInstance, force
Menu, Tray, Add , Kill, CloseAHKsock
SetBatchLines, -1
ListLines Off


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
DBLoc := "C:\TO_DB\todbmanager-master\to.db" ; Change to match the location name of your database as needed
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
    res.headers["Content-Type"] := "text/html; charset=utf-8"
    qstrg := req.queries["ids"] ; Enumerate the Query String Parameters
    Gosub getsql
    res.SetBodyText(body)
    res.status := 200
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
            type := info.Remove(1)
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

    ServeFile(ByRef response, file) {
        Loop
        {
            f := FileOpen(file, "r-wd")
            If IsObject(f)
            {
                length := f.RawRead(data, f.Length)
                f.Close()
                Break
            }
            Sleep, 0
        }
        response.SetBody(data, length)
        response.headers["Content-Type"] := this.GetMimeType(file)
        response.headers["Accept-Ranges"] := "bytes"
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
        ;OutputDebug, % "AHKsock_Listen...." AHKsock_Listen(port, "()")
        
               
        AHKsock_ErrorHandler("AHKsockErrors")
        ;OutputDebug, % "AHKsock_ErrorHandler...." AHKsock_ErrorHandler("""")
        
    }
}

HttpHandler(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, bDataLength = 0) {
    
    static sockets := {}
    
    
    if (!sockets[iSocket]) {
        sockets[iSocket] := new Socket(iSocket)
        ;SockOptions go here
        AHKsock_SockOpt(iSocket, "TCP_NODELAY", true)
        ;OutputDebug, % "Socket...." iSocket " AHKsock_SockOpt...SO_KEEPALIVE " AHKsock_SockOpt(iSocket, "SO_KEEPALIVE", -1) " SO_SNDBUF " AHKsock_SockOpt(iSocket, "SO_SNDBUF", -1) " SO_RCVBUF " AHKsock_SockOpt(iSocket, "SO_RCVBUF", -1) " TCP_NODELAY " AHKsock_SockOpt(iSocket, "TCP_NODELAY", -1) " ErrorLevel ..." ErrorLevel
    }
    
     
    
    socket := sockets[iSocket]
    
        
    
    if (sEvent == "DISCONNECTED") {
        ;OutputDebug, %  sEvent " Socket....." iSocket
        socket.request := false
        sockets[iSocket] := false
        return
    } else if (sEvent == "SEND" || sEvent == "SENDLAST") {
        if (socket.TrySend()) {
            ;OutputDebug, % "Success! Data Sent from a " sEvent " sEvent from Socket " iSocket
        }

    } else if (sEvent == "RECEIVED") {
        server := HttpServer.servers[sPort]

        text := StrGet(&bData, "UTF-8")

        ; New request or old?
        if (socket.request) {
            ; Get data and append it to the existing request body
            socket.request.bytesLeft -= StrLen(text)
            socket.request.body := socket.request.body . text
            request := socket.request
        } else {
            ; Parse new request
            request := new HttpRequest(text)

            length := request.headers["Content-Length"]
            request.bytesLeft := length + 0

            if (request.body) {
                request.bytesLeft -= StrLen(request.body)
            }
        }

        if (request.bytesLeft <= 0) {
            ;We're done
            request.done := true
        } else {
            socket.request := request
        }

        if (request.done || request.IsMultipart()) {
            response := server.Handle(request)
            ;OutputDebug % "request.done " request.done " request.IsMultipart() " request.IsMultipart() " response.status " response.status
            if (response.status) {
                socket.SetData(response.Generate())
            }
        }
        if (socket.TrySend()) {
            if (!request.IsMultipart() || request.done) {
                ;OutputDebug, % "Success! Data Sent from a " sEvent " sEvent from Socket " iSocket
                ;OutputDebug, % "Close Socket " iSocket " meesage from AHKsock_Close..... " AHKsock_Close(iSocket) " ErrorLevel " ErrorLevel
                return
            }
        }    

    }
    return
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

        this.GetPathInfo(headers.Remove(1))
        this.GetQuery()
        this.headers := {}

        for i, line in headers {
            pos := InStr(line, ":")
            key := SubStr(line, 1, pos - 1)
            val := Trim(SubStr(line, pos + 1), "`n`r ")

            this.headers[key] := val
        }
    }

    IsMultipart() {
        length := this.headers["Content-Length"]
        expect := this.headers["Expect"]

        if (expect = "100-continue" && length > 0)
            return true
        return false
    }
}

class HttpResponse
{
    __New() {
        this.headers := {}
        this.status := 0
        this.protocol := "HTTP/1.1"

        this.SetBodyText("")
    }

    Generate() {
        FormatTime, date,, ddd, d MMM yyyy HH:mm:ss
        this.headers["Date"] := date
        this.headers["Access-Control-Allow-Origin"] := "*"
        this.headers["Connection"] := "Keep-Alive: timeout=5, max=99"
        this.headers["Access-Control-Max-Age"] := "120"
        

        headers := this.protocol . " " . this.status . "`r`n"
        for key, value in this.headers {
            headers := headers . key . ": " . value . "`r`n"
        }
        
        
        headers := headers . "`r`n"
        length := this.headers["Content-Length"]

        buffer := new Buffer((StrLen(headers) * 2) + length)
        buffer.WriteStr(headers)

        buffer.Append(this.body)
        buffer.Done()

        return buffer
    }

    SetBody(ByRef body, length) {
        this.body := new Buffer(length)
        this.body.Write(&body, length)
        this.headers["Content-Length"] := length
    }

    SetBodyText(text) {
        this.body := Buffer.FromString(text)
        this.headers["Content-Length"] := this.body.length
    }


}

class Socket
{
    __New(socket) {
        this.socket := socket
    }

    SetData(data) {
        this.data := data
    }

    TrySend() {
        if (!this.data || this.data == "")
            return false

        p := this.data.GetPointer()
        length := this.data.length

        this.dataSent := 0
        loop {
            if ((i := AHKsock_Send(this.socket, p, length - this.dataSent)) < 0) {
                ;Check if we received WSAEWOULDBLOCK errors
                if (i == -2 || i== -5) {
                    return false ;We'll keep sending data the next time we get the SEND event
                } else { ;Something bad has happened
                    ;OutputDebug, % "Something bad has happened - AHKsock_Send failed with return value = " i " and ErrorLevel = " ErrorLevel
                    ;OutputDebug, % "Socket..." this.socket " from ....." sEvent "AHKsock_Close....." AHKsock_Close(this.socket) " ErrorLevel " ErrorLevel
                    return false 
                }
            }
            ;OutputDebug, % "Socket...." this.socket " AHKsock_SockOpt...SO_KEEPALIVE " AHKsock_SockOpt(this.socket, "SO_KEEPALIVE", -1) " SO_SNDBUF " AHKsock_SockOpt(this.socket, "SO_SNDBUF", -1) " SO_RCVBUF " AHKsock_SockOpt(this.socket, "SO_RCVBUF", -1) " TCP_NODELAY " AHKsock_SockOpt(this.socket, "TCP_NODELAY", -1) " ErrorLevel ..." ErrorLevel
            ;OutputDebug, % "We sent " i " bytes of " length " bytes total" 
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

class Buffer
{
    __New(len) {
        this.SetCapacity("buffer", len)
        this.length := 0
    }

    FromString(str, encoding = "UTF-8") {
        length := Buffer.GetStrSize(str, encoding)
        buffer := new Buffer(length)
        buffer.WriteStr(str)
        return buffer
    }

    GetStrSize(str, encoding = "UTF-8") {
        encodingSize := ((encoding="UTF-16" || encoding="CP1200") ? 2 : 1)
        ; length of string, minus null char
        return StrPut(str, encoding) * encodingSize - encodingSize
    }

    WriteStr(str, encoding = "UTF-8") {
        length := this.GetStrSize(str, encoding)
        VarSetCapacity(text, length)
        StrPut(str, &text, encoding)

        this.Write(&text, length)
        return length
    }

    ; data is a pointer to the data
    Write(data, length) {
        p := this.GetPointer()
        DllCall("RtlMoveMemory", "uint", p + this.length, "uint", data, "uint", length)
        this.length += length
    }

    Append(ByRef buffer) {
        destP := this.GetPointer()
        sourceP := buffer.GetPointer()

        DllCall("RtlMoveMemory", "uint", destP + this.length, "uint", sourceP, "uint", buffer.length)
        this.length += buffer.length
    }

    GetPointer() {
        return this.GetAddress("buffer")
    }

    Done() {
        this.SetCapacity("buffer", this.length)
    }
}

AHKsockErrors(iError, iSocket) {
    OutputDebug, % "Error " iError " with error code = " ErrorLevel ((iSocket <> -1) ? " on socket " iSocket "." : ".") 
}



#Include %A_ScriptDir%\Class_SQLiteDB.ahk
#Include <AHKsock>


CloseAHKsock:
; Closedown all winsock sockets and exit the app
AHKsock_Close()
ExitApp



