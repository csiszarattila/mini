require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../models/post'

describe 'Post' do
  
  it "should have comments" do
    post = Post.all.first
    
    post.add_comment @valid_comment
    
    post.comments.should have(1).item
  end
  
end