require 'lib/commentable'

class Article < ActiveDocument::Base
  include Commentable
  
  document_parsers( {".haml" => ActiveDocument::Parsers::Jaml, ".md" => ActiveDocument::Parsers::Yamd})
end