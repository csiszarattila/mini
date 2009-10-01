require File.dirname(__FILE__) + '/test_helper'

describe 'Mini' do
  include Rack::Test::Methods
  
  before :each do
    @a_comment_to_post = {
			'comment[name]' => "Ati",
			'comment[email]' => "csiszar.ati@gmail.com",
			'comment[website]' => "csiszarattila.com",
			'comment[body]' => "Lorem ipsum dolor sit amet, consectetur adipisicing elit
			sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
			Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.
			nisi ut aliquip ex ea commodo consequat.
			Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. 
			Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
		}
  end
  
  def app
    Sinatra::Application
  end
    
  it 'should have default page' do
    get '/'
    
    last_response.should be_ok
  end
  
  it 'should have rss feed' do
    get '/rss'
    
    last_response.should be_ok
    last_response.headers['Content-Type'].should match('text/html')
  end
  
  it 'should show documents in separate page by title' do
    post = Post.all.first
    post_prettified_title = post.prettify_filename
    get '/bejegyzesek/' + post_prettified_title
    
    last_response.should be_ok
    
    article = Article.all.first
    article_prettified_title = article.prettify_filename
    get '/cikkek/' + article_prettified_title
    
    last_response.should be_ok
    
    no_doc_title = 'pretty-fied-title'
    get '/cikkek/' + no_doc_title
    
    last_response.should_not be_ok
    last_response.status.should be(404)
  end
  
  it "should save posted comment for documents" do
    post '/bejegyzesek/sample-post/comments', @a_comment_to_post
    follow_redirect!
    
    last_request.url.should match( SITE_URL + '/bejegyzesek/sample-post' )
    last_response.should be_ok
  end
  
  it "should show errors if saving a comment is failed" do
    a_bad_comment = @a_comment_to_post
    a_bad_comment["comment[body]"] = "" # make an error
    post 'bejegyzesek/sample-post/comments', a_bad_comment
    
    last_response.should be_ok
    last_request.url.should match( '/bejegyzesek/sample-post/comments' )
    
    post = Post.find("sample_post")
    post.comments.should have(:no).item
  end
end