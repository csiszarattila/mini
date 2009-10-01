require File.dirname(__FILE__) + '/../mini'
require 'spec'
require 'rack/test'

Spec::Runner.configure do |config|
  config.before(:all) do
    @sample_post_name = "sample_post.haml"
    @sample_post_name_without_extension = "sample_post"    
  end
  
  config.before(:each) do
    # Use transactions to rollback db after each test case
    ActiveRecord::Base.connection.increment_open_transactions
    ActiveRecord::Base.connection.begin_db_transaction
    
    @a_valid_comment_body = "Lorem ipsum dolor sit amet.\r\nConsectetur adipisicing elit"
  	@valid_comment = Comment.new do |sample|
		  sample.name = "Csiszár Attila"
      sample.email = "csiszar.ati@gmail.com"
      sample.body = @a_valid_comment_body
      sample.website = "csiszarattila.com"
    end
  end
  
  config.after(:each) do
    # Rollback db to original state after each test case
    ActiveRecord::Base.connection.rollback_db_transaction
  end
end

set :environment, :test
