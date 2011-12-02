require 'socket'
include ObjectSpace

class Webserver
	ERRPAGE = '404.html'
	ERRTEXT = 'Error 404: Not found'
	INDEX = 'index.html'
	
	def initialize(host, port)
		@webserver = TCPServer.new(host, port)
		ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc)
		puts "Server started [#{host}:#{port}]."
	end
	
	def Webserver.finalize
		puts 'Server stopped.'
	end
	
	def start
		while(session = @webserver.accept)
			session.print "HTTP/1.1 200/OK\r\nContent-type:text/html\r\n\r\n"
			request = session.gets
			get = request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '').strip!
			session.print get == '' ? get_page(INDEX) : get_page(get)
			for i in 1..10 do
				session.print "\n<br />"
			end
			session.print '<p align="right"><em>A ruby webserver.</em></p>'
			session.close
		end
	end
	
	def get_notfound_page
		File.exists?(ERRPAGE) ? File.read(ERRPAGE) : ERRTEXT
	end
	
	def get_page(path)
		File.exists?(path) ? File.read(path) : get_notfound_page
	end
end
Webserver.new(ARGV[0]||'localhost', ARGV[1]||2020).start
