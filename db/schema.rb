require 'rubygems'
require 'activerecord'
ActiveRecord::Base.establish_connection(
	:adapter => 'sqlite3',
	:dbfile	=>	'db/mini.sqlite3.db'
)

ActiveRecord::Schema.define(:version=>1) do
	create_table :comments do |t|
		t.string :name, :email, :website
		t.text :body
		t.datetime :created_at
		t.string :document
	end
end