# TO-SQLHTTP-Server
An AutoHotkey script with an SQLite HTTP Server.


* Provides HTTP access to the stats Table from a to.db from toutils/todbmanger:


      todbmanager - https://github.com/toutils/todbmanager


#######################################################


Installation:


* Download, unzip, and install AHKsock.ahk in an AHK Standard Lib or AHK User Library (Documents\AutoHotkey\Lib):
  
  
      AHKsock - https://github.com/jleb/AHKsock




* Download and unzip into the SQLHTTP.ahk Script Working Directory (A_ScriptDir):


      AHKhttp - https://github.com/zhamlin/AHKhttp

      Class_SQLiteDB - https://github.com/AHK-just-me/Class_SQLiteDB
 

      Precompiled Binaries for Windows:
      
            sqlite-dll-{arch-version}.zip - https://sqlite.org/download.html
 
      


* Edit the SQLHTTP.ahk file.

    Change the DBLoc line to the location of your to.db database file:

        DBLoc := "C:\TO_DB\todbmanager-0.3\to.db" ; Change to match the location name of your database as needed



* Run the SQLHTTP.ahk script and the api server will be located at URL:

        http://127.0.0.1:8000/api/multi-attrs.php?ids=requesterid


#######################################################


SQLTables.ahk - A script to list the names of the SQL tables in a to.db

* Edit the SQLTables.ahk file.

    Change the DBLoc line to the location of your to.db database file:

        DBLoc := "C:\TO_DB\todbmanager-0.3\to.db" ; Change to match the location name of your database as needed
