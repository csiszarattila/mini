require 'rubygems'
require 'sinatra'
require 'activerecord'
require File.dirname(__FILE__) + '/vendor/active_document/lib/active_document'

ActiveDocument::Base.has_documents_in File.dirname(__FILE__) + '/documents/'
ActiveDocument::Base.document_parser ActiveDocument::Parsers::Jaml

require File.dirname(__FILE__) + '/lib/core_ext/date'
require File.dirname(__FILE__) + '/models/comment'
require File.dirname(__FILE__) + '/models/article'
require File.dirname(__FILE__) + '/models/post'

# 
# Sinatra application
# 
class Mini < Sinatra::Application
  
set :environment, :command_line

set :views, File.dirname(__FILE__) + '/views'

configure :test do
	SITE_URL = "http://minitest.com"
	DB_FILE = "mini.test.sqlite3.db"
end

configure :development do
	SITE_URL = "http://local.csiszarattila.com/rubysztan"
	DB_FILE = "mini.sqlite3.db"
	require 'haml'
end

configure :command_line do
	SITE_URL = "/rubysztan"
	DB_FILE = "mini.sqlite3.db"
	require 'haml'
end

configure :production do
	SITE_URL = "http://csiszarattila.com/rubysztan"
	DB_FILE = "mini.sqlite3.db"
end

# 
# ActiveRecord kapcsolat a Comment modellnek
#
ActiveRecord::Base.establish_connection( 
  :adapter => 'sqlite3',	
  :dbfile	=>	File.dirname(__FILE__) + '/db/' + DB_FILE 
)

before do
	request.path_info = request.path_info.gsub(/^\/rubysztan/,"")
end

helpers do
	def link_to title, href
		Haml::Engine.new("%a{:href=>'#{href}'}#{title}").render
	end

	def article_path(article)
		site_url + "/cikkek/" + article.prettify_filename
	end

	def article_image_path(article)
		site_url + "/images/cikkek/" + article.image_path
	end

	def comments_path(document)
		self.send("#{document.class.to_s.downcase + "_comments_path"}",document)
	end

	def post_path(post)
		site_url + "/bejegyzesek/" + post.prettify_filename
	end
	
	def doc_path(doc)
	  if doc.kind_of? Article
	    article_path(doc)
	  elsif doc.class.kind_of? Post 
	    post_path(doc)
    end
  end

	def article_comments_path(article)
		"#{article_path(article)}/comments#add-comment"
	end

	def post_comments_path(post)
		"#{post_path(post)}/comments#add-comment"
	end

	def gravatar_tag(comment, size=40)
	  require 'md5'
	  
		mail = comment.email || ""
		hash = MD5::md5(mail.downcase)
		image_src = "http://www.gravatar.com/avatar/#{hash}?s=#{size}"
		"<img class='gravatar' src=#{image_src}></img>"
	end

	def rss_url()
		"http://feeds.feedburner.com/rubysztan"
	end

	def rss_link(options={})
		"<link href='#{rss_url}' title='#{options[:title]}' rel='alternate' type='application/rss+xml'/>"
	end

	def site_url
		SITE_URL
	end
end

get '/' do
	@posts = Post.all.sort {|p, obj| obj.created_at <=> p.created_at }
	@articles = Article.all.sort {|p, obj| obj.created_at <=> p.created_at }
	haml :index
end

get '/cikkek/rss' do
end

get '/rss' do
	@docs = (Post.all + Article.all).sort { |p, obj| obj.created_at <=> p.created_at }

	builder do |xml|
		xml.instruct! :xml, :version => '1.0'
		xml.rss :version => "2.0", "xmlns:atom"=>"http://www.w3.org/2005/Atom" do
			xml.channel do
				xml.title "Rubysztán"
				xml.description "Minden ami Ruby."
				xml.link site_url
				xml.atom :link, 
												:href	=>	rss_url,
												:rel	=>	"self",
												:type	=>	"application/rss+xml"
			
				@docs.each do |doc|
					xml.item do
						xml.title doc.title
						xml.link doc_path(doc)
						xml.description doc.body
						xml.pubDate Time.parse(doc.created_at.to_s).rfc822()
						xml.guid doc_path(doc)
					end
				end
			end
		end
	end
end


# get /bejegyzesek/:title
# get /cikkek/:title
get '/:document_type/:title' do
  begin
  
  title = params[:title]
	case params["document_type"]
    when "bejegyzesek" :
  	  @document = Post.find_by_prettified_title(params[:title])
			document_url = post_path(@document) + "#comments"
    when "cikkek" :
      @document = Article.find_by_prettified_title(params[:title])
			document_url = article_path(@document) + "#comments"
	end
	
	@comment = Comment.new()
	haml :document
	
	rescue ActiveDocument::DocumentNotFound
	 	raise Sinatra::NotFound
	end
end

# post /bejegyzesek/:title/comments
# post /cikkek/:title/comments
post '/:document_type/:title/comments' do
	case params["document_type"]
  when "bejegyzesek" :
    @document = Post.find_by_prettified_title(params[:title])
		document_url = post_path(@document) + "#comments"
  when "cikkek" :
    @document = Article.find_by_prettified_title(params[:title])
		document_url = article_path(@document) + "#comments"
	end
	
  redirect document_url and return unless params["filter"] == ''
	@comment = Comment.new(params[:comment])
  if @document.add_comment( @comment )
		redirect document_url
	else
		haml :document
	end
end

end
