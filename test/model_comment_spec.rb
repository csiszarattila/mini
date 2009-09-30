require File.dirname(__FILE__) + '/../models/comment'

describe "Comment" do
  
  before :each do
    
    @a_valid_comment_body = "Lorem ipsum dolor sit amet.\r\nConsectetur adipisicing elit"
		  
		@valid_comment = Comment.new do |sample|
		  sample.name = "Csiszár Attila"
      sample.email = "csiszar.ati@gmail.com"
      sample.body = @a_valid_comment_body
      sample.website = "csiszarattila.com"
    end
  end
  
  
  it "should not save empty comment" do
    comment = Comment.new
    
    comment.should be_true
    comment.save.should_not be_true
  end
  
  it "should only be saved if it has a body and an author at least" do
    comment = Comment.new
    
    comment.name = "Csiszár Attila"
    comment.save.should_not be_true
    
    comment.email = "csiszar.ati@gmail.com"
    comment.save.should_not be_true
    
    comment.body = @a_valid_comment_body
    comment.save.should be_true
    comment.should have(:no).errors
    
    comment = @valid_comment
    comment.name = nil
    comment.body = nil
    comment.save.should_not be_true
  end
  
  it "should not be saved with blank body" do
     comment = @valid_comment

     comment.body = ""
     comment.save.should_not be_true
     comment.should_not be_valid
     comment.errors.on(:body).should match("can't be blank") 
   end
  
  it "should convert line-feeds into <br> tag" do
    comment = @valid_comment
    comment.save
    with_line_feeds_converted_into_br_tags = "Lorem ipsum dolor sit amet.<br />Consectetur adipisicing elit"
    
    comment = Comment.last
    comment.body.should match(with_line_feeds_converted_into_br_tags)
  end
end