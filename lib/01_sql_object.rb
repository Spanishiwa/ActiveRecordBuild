require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @column_names.first if @column_names
    @column_names = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      "#{self.table_name}"
    SQL
    @column_names.first.map!(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |attr_name|
      define_method("#{attr_name}") do
        self.attributes[attr_name]
      end

      define_method("#{attr_name}=") do |value|
        self.attributes[attr_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    if @table_name.nil?
      self.to_s.tableize
    else
      @table_name
    end
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      "#{self.table_name}".*
    FROM
      "#{self.table_name}"
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map{ |hash| self.new(hash) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      "#{table_name}".*
    FROM
      "#{table_name}"
    WHERE
      "#{table_name}".id = ?
    SQL
    parse_all(results).first
  end

  def initialize(params = {})
    params.each do |attr_name, attr_val|
      if self.class.columns.include?(attr_name.to_sym)
        self.send("#{attr_name.to_sym}=", attr_val)
      else
        raise Exception.new("unknown attribute '#{attr_name}'")
      end
    end
  end

  def attributes
    @attributes = {} if @attributes.nil?
    @attributes
  end

  def attribute_values
    values = []
    self.class.columns.each do |attribute|
      values << self.send(attribute)
    end
    values
  end

  def insert
    col_names = self.class.columns.join(', ')
    num = self.class.columns.length
    var_arr = Array.new(num, "#{?}" )
    byebug
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
