require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../models/post'

describe 'Post' do
  
  it "should have comments" do
    post = Post.all.first
    
    comment = @valid_comment
    comment.document = post.filename
    comment.save
    
    post.comments.should have(1).item
  end
  
end