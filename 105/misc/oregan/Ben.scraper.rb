class BenScanner < RSSscraper::AbstractScanner
	def initialize
		@url_string = 'http://okopnik.freeshell.org/blog/blog.cgi'
		@url_proper = 'http://okopnik.freeshell.org/blog/'
		@postsRE = /div class="HeadText"> \n\n([^<]*)\n\n<\/div>\n<\/td>\n<\/tr>\n\n<tr>\n<td bgcolor="#fdfded" class="UsualText" valign="middle">  \n\n<br><b>([^<]*)<\/b><p>\n\n([^\]]*)\n\n<p>\[ <a href="([^\s\t\r\n\f]*)">([^<]*)<\/a>/m
	end

	def find_items
		require 'cgi'
		items = Array.new
 		request_feed.scan(@postsRE).each{ |date, title, content, comments_link, comments|
                        items << { :title => title,
                                   :description => "#{CGI::escapeHTML(content)}",
                                   :comments_link => @url_proper+comments_link,
                                   :comments => @url_proper+comments_link,
                                 }
		}
		items
	end
end

class Ben < RSSscraper::AbstractScraper

	def scanner
		BenScanner.new
	end

	def description
	{
		:link => 'http://okopnik.freeshell.org/blog/blog.cgi',
		:title => 'The Bay of Tranquility',
		:description => 'Ben Okopnik\'s blog.',
		:language => 'en-us',
		:generator => generator_string
	}	
	end

end
