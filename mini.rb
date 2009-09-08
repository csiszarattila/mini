require 'rubygems'
require 'activerecord'
require 'md5'
require File.dirname(__FILE__) + '/vendor/active_document/lib/active_document'

ActiveDocument::Base.has_documents_in File.dirname(__FILE__) + '/documents'
autoload :Post, File.dirname(__FILE__) + '/models/post'
autoload :Article, File.dirname(__FILE__) + '/models/article'

# 
# Lokalizációs felülírás a magyar hónapnevekre
# 
class Date
	def to_format(format)
		hun_month_names = %w[zero Január Február Március Április Május Június] + 
			%w[Július Augusztus Szeptember Október November December]
		format.gsub!(/%B/,hun_month_names[self.month])
		self.strftime(format)
	end
end


# 
# ActiveRecord kapcsolat a Comment modellnek
# 
ActiveRecord::Base.establish_connection(
	:adapter => 'sqlite3',
	:dbfile	=>	'rubisztan.sqlite3.db'
)

# 
# Sinatra alkalmazás
# 
	
	set :environment, :production
	
	configure :development do
		SITE_URL = "http://local.csiszarattila.com/rubysztan" 
		require 'haml'
	end

	configure :production do
		SITE_URL = "http://csiszarattila.com/rubysztan"
	end
  
	before do
		request.path_info = request.path_info.gsub(/^\/rubysztan/,"")
	end

	helpers do
		def link_to title, href
			Haml::Engine.new("%a{:href=>'#{href}'}#{title}").render
		end
	
		def article_path(article)
			site_url + "/cikkek/" + Article.translate_filename_to_title(article.file)
		end
	
		def article_image_path(article)
			site_url + "/images/cikkek/" + article.image_path
		end
	
		def comments_path(document)
			self.send("#{document.class.to_s.downcase + "_comments_path"}",document)
		end
	
		def post_path(post)
			site_url + "/bejegyzesek/" + Post.translate_filename_to_title(post.file)
		end
	
		def article_comments_path(article)
			"#{article_path(article)}/comments#add-comment"
		end
	
		def post_comments_path(post)
			"#{post_path(post)}/comments#add-comment"
		end
	
		def gravatar_tag(comment, size=40)
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
		@posts = Post.all.sort { |p, obj| obj.created_at <=> p.created_at }
	
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
				
					@posts.each do |post|
						xml.item do
							xml.title post.title
							xml.link post_path(post)
							xml.description post.body
							xml.pubDate Time.parse(post.created_at.to_s).rfc822()
							xml.guid post_path(post)
						end
					end
				end
			end
		end
	end


	# get /bejegyzesek/:title
	# get /cikkek/:title
	get '/:document_type/:title' do
		# begin
			if params["document_type"] == "bejegyzesek"
				@document = Post.find_by_title(params[:title])
			elsif params["document_type"] == "cikkek"
				@document = Article.find_by_title(params[:title])
			end
			@comment = Comment.new()
			haml :document
		# rescue RecordNotFound
		# 	raise Sinatra::NotFound
		# end
	end

	# post /bejegyzesek/:title/comments
	# post /cikkek/:title/comments
	post '/:document_type/:title/comments' do
		if params["document_type"] == "bejegyzesek"
			@document = Post.find_by_title(params[:title])
			document_url = post_path(@document) + "#comments"
		elsif params["document_type"] == "cikkek"
			@document = Article.find_by_title(params[:title])
			document_url = article_path(@document) + "#comments"
		end
	
		@comment = Comment.new(params[:comment])
		@comment.post_id = @document.id
	
		if @comment.save
			redirect document_url
		else
			haml :document
		end
	end
	
#
# Modellek
# 
class Comment < ActiveRecord::Base
	validates_presence_of :name, :body
	
	def before_save
		self.body = read_attribute(:body).gsub(/\r\n/,"<br />")
	end
end

#
# Az ActiveRecord::RecordNotFound imitálása a Document osztályhoz
# 
class RecordNotFound < Exception 
end
