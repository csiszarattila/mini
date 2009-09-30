class Comment < ActiveRecord::Base
	validates_presence_of :name, :body
	
	def before_save
		self.body = read_attribute(:body).gsub(/\r\n/,"<br />")
	end
end