require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../models/post'

describe 'Article' do
  it "should have comments" do
    article = Article.all.first
    
    article.add_comment @valid_comment
    
    article.comments.should have(1).item
  end
  
end