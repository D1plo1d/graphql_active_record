ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :key
    t.string :name
    t.integer :age
    t.datetime :dob
    t.timestamps
  end

  create_table :pets, :force => true do |t|
    t.belongs_to :user
    t.string :name
    t.integer :age
    t.datetime :dob
    t.timestamps
  end

end