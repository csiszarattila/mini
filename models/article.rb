class Article < ActiveDocument::Base
	def comments
		Comment.find_all_by_document(filename)
	end
end