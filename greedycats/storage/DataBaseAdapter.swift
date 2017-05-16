//
//  DataBaseAdapter.swift
//  Greedy Cats
//
//  Created by David Yuste on 2/24/15.
//  Copyright (c) 2015 David Yuste Romero
//
//  THIS MATERIAL IS PROVIDED AS IS, WITH ABSOLUTELY NO WARRANTY EXPRESSED
//  OR IMPLIED.  ANY USE IS AT YOUR OWN RISK.
//
//  Permission is hereby granted to use or copy this program
//  for any purpose,  provided the above notices are retained on all copies.
//  Permission to modify the code and to distribute modified code is granted,
//  provided the above notices are retained, and a notice that the code was
//  modified is included with the above copyright notice.
//

import Foundation

class DataBaseTraverserIterator {
	private var statement_ : COpaquePointer
	private var generator_ : DataBaseTraverserGenerator
	
	init (statement : COpaquePointer, generator : DataBaseTraverserGenerator) {
		self.statement_ = statement
		self.generator_ = generator
	}
	
	func isNull(col : Int32) -> Bool {
		return sqlite3_column_type(statement_, col) == SQLITE_NULL
	}
	
	func colAsInt32(col : Int32) -> Int32 {
		let rowData = sqlite3_column_int(statement_, col)
		return Int32(rowData)
	}
	
	func colAsUInt32(col : Int32) -> UInt32 {
		let rowData = sqlite3_column_int(statement_, col)
		return UInt32(rowData)
	}
	
	func colAsInt64(col : Int32) -> Int64 {
		let rowData = sqlite3_column_int64(statement_, col)
		return Int64(rowData)
	}
	
	func colAsUInt64(col : Int32) -> UInt64 {
		let rowData = sqlite3_column_int64(statement_, col)
		return UInt64(rowData)
	}
	
	func colAsNSNumber(col : Int32) -> NSNumber {
		let rowData = sqlite3_column_int64(statement_, col)
		return NSNumber(longLong: rowData)
	}
	
	func colAsString(col : Int32) -> String {
		let rowData = sqlite3_column_text(statement_, col)
		return String.fromCString(UnsafePointer<CChar>(rowData))!
	}
}

class DataBaseTraverserGenerator: GeneratorType {
	private var sql_: String
	private var statement_ : COpaquePointer
	private var dataBase_ : COpaquePointer
	
	init(sql: String) {
		self.sql_ = sql
		self.statement_ = nil
		self.dataBase_ = nil
	}
	
	deinit {
		if dataBase_ != nil {
			DataBaseAdapter.Singleton.releaseSharedDataBase()
		}
		
		if statement_ != nil {
			sqlite3_finalize(statement_)
		}
	}
		
	func next() -> DataBaseTraverserIterator? {
		if self.statement_ == nil {
			dataBase_ = DataBaseAdapter.Singleton.getSharedDataBase()
			Logger.Debug("DataBaseTraverserGenerator::next: Running query \(sql_)")
			let prepareResult = sqlite3_prepare_v2(dataBase_, sql_, -1, &statement_, nil)
			if statement_ == nil || prepareResult != SQLITE_OK {
				let errmsg = String.fromCString(sqlite3_errmsg(dataBase_))
				Logger.Error("DataBaseTraverserGenerator::next: sqlite3_prepare_v2 failed with '\(errmsg)' for SQL '\(sql_)'")
				return nil
			}
		}
		let value = sqlite3_step(statement_)
		if value == SQLITE_ROW {
			return DataBaseTraverserIterator(statement: statement_, generator: self)
		} else {
			sqlite3_finalize(statement_)
			statement_ = nil
			return nil
		}
	}
}

class DataBaseTraverser : SequenceType {
	init (sql : String) {
		self.sql_ = sql
	}
	
	func begin() -> DataBaseTraverserIterator? {
					let generator : DataBaseTraverserGenerator = DataBaseTraverserGenerator(sql: sql_)
		return generator.next()
	}
	
	func generate() -> DataBaseTraverserGenerator {
		return DataBaseTraverserGenerator(sql: sql_)
	}
				
	private var sql_ : String
}

let TableSettings = "settings"
let TableGame = "bom_game";
let TableUser = "bom_user";
let TableVirtualUser = "bom_virtual_user";
let TableGamePlayers = "bom_game_players";
let TableGameCells = "bom_game_cells";

class DataBaseAdapter {
	
	class var Singleton : DataBaseAdapter {
		struct singleton {
			static let instance = DataBaseAdapter()
		}
		return singleton.instance
	}
	
	init() {
		sharedDataBase = nil
		sharedDataBaseClients = 0
		initializeConnection()
		bootStrap()
	
	}
	
	
// MARK: Queries
	
	func executeInsert(table: String, fields: String, values: String) {
		let sql : String = "INSERT INTO \(table) (\(fields)) VALUES \(values)"
		executeChange(sql)
	}
	
	func executeInsertOrReplace(table: String, fields: String, values: String) {
		let sql : String = "INSERT OR REPLACE INTO \(table) (\(fields)) VALUES \(values)"
		executeChange(sql)
	}
	
	func executeChange(sql: String) -> Bool {
		var status = false
		let dataBase : COpaquePointer = getSharedDataBase()
		if dataBase != nil {
			var errMsg:UnsafeMutablePointer<Int8> = nil
			let result = sqlite3_exec(dataBase, sql, nil, nil, &errMsg)
			if result != SQLITE_OK {
				Logger.Error("DataBaseAdapter::executeChange: \(String.fromCString(UnsafePointer<CChar>(errMsg))!), for SQL '\(sql)'")
				status = false
			} else {
				status = true
			}
		}
		releaseSharedDataBase()
		return status
	}
	
// MARK: Connection
	
	let DataBaseName : String = "datamodel.db"
	private var dataBaseFile : String?
	private var sharedDataBase : COpaquePointer
	private var sharedDataBaseClients : Int
	
	func getSharedDataBase() -> COpaquePointer {
		if sharedDataBase == nil {
			let result = sqlite3_open(dataBaseFile!, &sharedDataBase)
			if (result != SQLITE_OK) {
				Logger.Error("DataBaseAdapter::getSharedDataBase: Failed to open")
				return nil
			}
		}
		++sharedDataBaseClients;
		return sharedDataBase
	}
	
	func releaseSharedDataBase() {
		--sharedDataBaseClients
		if sharedDataBaseClients == 0 {
			sqlite3_close(sharedDataBase)
			sharedDataBase = nil
		}
	}
	
	private func getDataBaseFilePath() -> String {
		let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let docsDir = dirPaths[0] 
		return (docsDir as NSString).stringByAppendingPathComponent(DataBaseName)
	}
	
// MARK: Initialization
	
	private func initializeConnection() {
		let file = getDataBaseFilePath()
		let fileManager = NSFileManager.defaultManager()
		if fileManager.fileExistsAtPath(file) {
			dataBaseFile = file
		}
	}
	
	private func bootStrap() {
		if dataBaseFile != nil {
			return;
			// Uncomment for database reset (for development)
			//var error:NSError?
			//var ok:Bool = NSFileManager.defaultManager().removeItemAtPath(dataBaseFile!, error: &error)
			//Logger.Log("DataBaseAdapter::bootStrap: Deleted database at \(dataBaseFile) : success \(ok)")
		}
		dataBaseFile = getDataBaseFilePath()
		Logger.Debug("DataBaseAdapter::bootStrap: database at \(dataBaseFile)")
		var dataBase:COpaquePointer = nil
		let result = sqlite3_open(dataBaseFile!, &dataBase)
		if (result == SQLITE_OK) {
			
			createTableIfNotExists(TableSettings, fields:
				"key VARCHAR(64) PRIMARY KEY, " +
				"value VARCHAR(256)",
				dataBase: dataBase
			);
			
			createTableIfNotExists(TableUser, fields:
				"id BIGINT UNSIGNED NOT NULL PRIMARY KEY, " +
				"user_name VARCHAR(32) NOT NULL, " +
				"name VARCHAR(64), " +
				"email VARCHAR(64), " +
				"picture_url VARCHAR(256) DEFAULT NULL, " +
				"theme BIGINT UNSIGNED NOT NULL DEFAULT 0, " +
				"lifes INT UNSIGNED NOT NULL DEFAULT 10, " +
				"score INT UNSIGNED NOT NULL DEFAULT 0, " +
				"about TEXT DEFAULT NULL, " +
				"time_stamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ",
				dataBase: dataBase
			);
				
			createTableIfNotExists(TableVirtualUser, fields:
				"id BIGINT UNSIGNED NOT NULL PRIMARY KEY, " +
				"user_name VARCHAR(32) NOT NULL, " +
				"name VARCHAR(64) NOT NULL, " +
				"picture_url VARCHAR(256) DEFAULT NULL, " +
				"theme BIGINT UNSIGNED NOT NULL DEFAULT 0, " +
				"lifes INT UNSIGNED NOT NULL DEFAULT 10, " +
				"score INT UNSIGNED NOT NULL DEFAULT 0, " +
				"about TEXT DEFAULT NULL, " +
				"time_stamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ",
				dataBase: dataBase
			);
				
			createTableIfNotExists(TableGame, fields:
				"id BIGINT UNSIGNED NOT NULL PRIMARY KEY, " +
				"sequence_num BIGINT UNSIGNED DEFAULT 0, " +
				"width TINYINT UNSIGNED NOT NULL DEFAULT 0, " +
				"height TINYINT UNSIGNED NOT NULL DEFAULT 0, " +
				"owner_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0, " +
				"turn_player_id BIGINT UNSIGNED NOT NULL DEFAULT 0, " +
				"random_game TINYINT DEFAULT 0, " +
				"finished TINYINT DEFAULT 0, " +
				"time_stamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ",
				dataBase: dataBase
			);
		
			createIndex(TableGame, index:"owner_user_id", fields:"owner_user_id", dataBase: dataBase);
			createIndex(TableGame, index:"turn_player_id", fields:"turn_player_id", dataBase: dataBase);
		
			createTableIfNotExists(TableGamePlayers, fields:
				"player_id BIGINT UNSIGNED NOT NULL, " +
				"game_id BIGINT UNSIGNED NOT NULL, " +
				"user_id BIGINT UNSIGNED DEFAULT NULL, " +
				"virtual_user_id BIGINT UNSIGNED DEFAULT NULL, " +
				"can_move TINYINT NOT NULL DEFAULT 1, " +
				"score INT UNSIGNED NOT NULL DEFAULT 0",
				dataBase: dataBase
			);
		
			createIndex(TableGamePlayers, index:"unicity", fields:"game_id,player_id", dataBase: dataBase);
			createIndex(TableGamePlayers, index:"game_id", fields:"game_id", dataBase: dataBase);
			createIndex(TableGamePlayers, index:"player_id", fields:"player_id", dataBase: dataBase);
			createIndex(TableGamePlayers, index:"user_id", fields:"user_id", dataBase: dataBase);
			createIndex(TableGamePlayers, index:"virtual_user_id", fields:"virtual_user_id", dataBase: dataBase);
			
			createTableIfNotExists(TableGameCells, fields:
				"game_id BIGINT UNSIGNED NOT NULL, " +
				"position SMALLINT UNSIGNED NOT NULL, " +
				"player_id BIGINT UNSIGNED DEFAULT NULL, " +
				"resources SMALLINT UNSIGNED NOT NULL DEFAULT 5, " +
				"state SMALLINT UNSIGNED NOT NULL DEFAULT 1",
				dataBase: dataBase
			);
		
			createUniqueIndex(TableGameCells, index:"unicity", fields:"game_id,position", dataBase: dataBase);
			createIndex(TableGameCells, index:"game_id", fields:"game_id", dataBase: dataBase);
			createIndex(TableGameCells, index:"player_id", fields:"player_id", dataBase: dataBase);
			createIndex(TableGameCells, index:"position", fields:"position", dataBase: dataBase);
			createIndex(TableGameCells, index:"game_id", fields:"game_id", dataBase: dataBase);
				
			sqlite3_close(dataBase)
			dataBase = nil
			
			//DataManager.Singleton.setSetting("version", value: "1.0.0")
			executeInsertOrReplace(TableSettings, fields: "key,value", values: "('version','1.0.0')")
		} else {
			Logger.Error("DataBaseAdapter::bootStrap: Failed to open DataBase")
		}
		
	}
	
	private func createTableIfNotExists(tableName : String, fields : String, dataBase : COpaquePointer) {
		var errMsg:UnsafeMutablePointer<Int8> = nil
		let sqlStmt = "CREATE TABLE IF NOT EXISTS \(tableName) (\(fields))";
		let result = sqlite3_exec(dataBase, sqlStmt, nil, nil, &errMsg)
		if result != SQLITE_OK {
			Logger.Error("DataBaseAdapter::createTableIfNotExists: \(String.fromCString(UnsafePointer<CChar>(errMsg))!) for SQL '\(sqlStmt)'")
		}
	}
			
	private func createIndex(tableName : String, index : String, fields : String, dataBase : COpaquePointer) {
		var errMsg:UnsafeMutablePointer<Int8> = nil
		let sqlStmt = "CREATE INDEX IF NOT EXISTS \(index) ON \(tableName) (\(fields))";
		let result = sqlite3_exec(dataBase, sqlStmt, nil, nil, &errMsg)
		if result != SQLITE_OK {
			Logger.Error("DataBaseAdapter::createIndex: \(String.fromCString(UnsafePointer<CChar>(errMsg))!) for SQL '\(sqlStmt)'")
		}
	}
			
	private func createUniqueIndex(tableName : String, index : String, fields : String, dataBase : COpaquePointer) {
		var errMsg:UnsafeMutablePointer<Int8> = nil
		let sqlStmt = "CREATE UNIQUE INDEX IF NOT EXISTS \(index) ON \(tableName) (\(fields))";
		let result = sqlite3_exec(dataBase, sqlStmt, nil, nil, &errMsg)
		if result != SQLITE_OK {
			Logger.Error("DataBaseAdapter::createUniqueIndex: \(String.fromCString(UnsafePointer<CChar>(errMsg))!) for SQL '\(sqlStmt)'")
		}
	}
}
