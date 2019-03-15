# TO-SQLHTTP-Server
TOSQLHTTP.ahk - An AutoHotkey script with an SQLite HTTP Server.


* Provides HTTP access to the stats Table for a to.db from toutils/todbmanger:


      todbmanager - https://github.com/toutils/todbmanager


#######################################################


Installation:


* Download, unzip, and install AHKsock.ahk in an AHK Standard Lib or AHK User Library (Documents\AutoHotkey\Lib):
  
  
      AHKsock - https://github.com/jleb/AHKsock




* Download and unzip into the TOSQLHTTP.ahk script directory:


      AHKhttp - https://github.com/zhamlin/AHKhttp

      Class_SQLiteDB - https://github.com/AHK-just-me/Class_SQLiteDB
 
      SQLite Download Precompiled Binaries for Windows:
      
            sqlite-dll-{arch-version}.zip - https://sqlite.org/download.html
 
      


* Edit the TOSQLHTTP.ahk file and change the DBLoc to the location of your to.db database file:

        DBLoc := "C:\TO_DB\todbmanager-0.3\to.db" ; Change to match the location name of your database as needed



* Run the TOSQLHTTP.ahk script and the HTTP server will be located at URL:

        http://127.0.0.1:8000/api/multi-attrs.php?ids=requesterid


#######################################################


TOSQLTables.ahk - A script to display the names of the SQL tables in a to.db

* Edit the TOSQLTables.ahk file and change the DBLoc to the location of your to.db database file:

        DBLoc := "C:\TO_DB\todbmanager-0.3\to.db" ; Change to match the location name of your database as needed