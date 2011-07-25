require 'cgi'
require 'open-uri'
require 'rexml/document'
require 'rubygems'
require 'hpricot'
 
class Ripper 
  
  def self.rip_one    
        xspf = "http://915.kuscstream.org:8000/kuscaudio128.mp3.xspf"
        open( xspf ) do |http|
          response = http.read
     
          xml = REXML::Document.new( response )
          xml.elements.each do |t|
            #puts t
          end
  
          open("current_title.xml", "wb") { |file|
        		file.write(response)
          }
 
          begin
              @small_doc= Hpricot(response)
              #puts response
              title = ""
              @small_doc.search("title").each{ |e|
                title =  e.to_plain_text 
            }
    
                split_title = title.split(' - ')
                artist = split_title[0]
                split_title.delete_at(0)
                song_title = split_title.join('-')
  
                p "artist #{artist}"
                p "songtitle = #{song_title}"
                p "Song: #{title}"
 
                open(File.expand_path("~/Library/Application\ Support/Nicecast/NowPlaying.txt"), "wb") { |file|
        		    file.write("Title: #{song_title}\nArtist: #{artist}\nAlbum: NOTUSED\nTime: 00:00 ")
        	    }
          end
      end   
  end 
end

Ripper.rip_one

