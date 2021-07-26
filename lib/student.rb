require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table #creates the students table in the database
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table #drops the students table from the database
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql) 
  end

  def save
    if self.id
      self.update
    else          #saves an instance of the Student class to the database and then sets the given students `id` attribute
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade) #creates a student with two attributes, name and grade, and saves it into the students table.
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(array) #creates an instance with corresponding attribute values
    id = array[0]
    name = array[1]
    grade = array[2]
    self.new(id, name, grade)
  end

  def update #updates the record associated with a given instance
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.find_by_name(name) #returns an instance of student that matches the name from the DB
    sql = "SELECT * FROM students WHERE name = ? LIMIT 1"
    result = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end


end
