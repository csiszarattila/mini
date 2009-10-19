require 'lib/commentable'

class Article < ActiveDocument::Base
  include Commentable
end