#NoEnv
#SingleInstance force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
db := new SQLiteDB
DBLoc := "C:\TOdb\todbmanager-0.3\to.db" ; Change to match the location of your database as needed
DBAccess := "R" ; Open db Readonly
db.OpenDB(DBLoc, DBAccess)
TableLookup := "select name from sqlite_master where type='table';" ; This will produce a list of all tables in the Database
db.GetTable(TableLookup, Result)
db.CloseDB()
Loop % Result.RowCount
{
I := A_Index ; Set the row value for each row loop
     Loop % Result.ColumnCount
          {
          msgbox % "Table Name: " . Result.Rows[I, A_Index] ; show the name of each table in the database
          }
}

exitApp

#Include %A_ScriptDir%\Class_SQLiteDB.ahk
