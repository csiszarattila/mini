require 'lib/commentable'

class Post < ActiveDocument::Base	
  include Commentable
end