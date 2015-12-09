require_relative 'db_connection.rb'
require 'active_support/inflector'
require_relative 'associatable'

class ActiveRecordObject

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", value)
      end
    end
  end

  def self.finalize!
    self.columns.each do |column|
      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
      define_method(column) do
        self.attributes[column]
      end
    end
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    objectify(results)
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    objectify(results)
  end

  def self.where(attributes)
    where = attributes.keys.map { |key| "#{key} = ?" }.join(" AND ")

    results = DBConnection.execute(<<-SQL, *attributes.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where}
    SQL

    objectify(results)
  end

  def insert
    columns = self.class.columns.drop(1)
    column_names = columns.map(&:to_s).join(", ")
    query_params = columns.map{|param| "?"}.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{column_names})
      VALUES
        (#{query_params})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set = self.class.columns.map{ |attr| "#{attr} = ?"}.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end

  def self.columns
    return @columns if @columns

    cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        0
    SQL

    @columns = cols.first.map!(&:to_sym)
  end


  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attribute| self.send(attribute) }
  end

  def self.objectify(attributes)
    attributes = attributes.map { |attribute| self.new(attribute) }
    attributes
  end

end
