require 'sqlite3'

ROOT = File.join(File.dirname(__FILE__), "..")
USERS_SQL = File.join(ROOT, "users.sql")
USERS_DB = File.join(ROOT, "users.db")

class DBConnection

  def self.reset
    commands = [
      "rm '#{USERS_DB}'",
      "cat '#{USERS_SQL}' | sqlite3 '#{USERS_DB}'"
    ]

    commands.each { |command| `#{command}` }
    DBConnection.open(USERS_DB)
  end

  def self.open(db_file)
    @database = SQLite3::Database.new(db_file)
    @database.results_as_hash = true
    @database.type_translation = true
    @database
  end

  def self.database_object
    reset if @database.nil?
    @database
  end

  def self.execute(*args)
    database_object.execute(*args)
  end

  def self.execute2(*args)
    database_object.execute2(*args)
  end

  def self.last_insert_row_id
    database_object.last_insert_row_id
  end

end
