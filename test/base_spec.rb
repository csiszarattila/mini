require File.dirname(__FILE__) + '/test_helper'

describe 'Mini' do
  include Rack::Test::Methods
  
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
end