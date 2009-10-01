class Post < ActiveDocument::Base	
	def comments
		Comment.find_all_by_document(filename)
	end
	
	def add_comment comment
    comment.document = filename
    comment.save
  end
end