class Post < ActiveDocument::Base	
	def comments
		Comment.find_all_by_post_id(id)
	end
end