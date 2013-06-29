require 'cgi'
require 'open-uri'
require 'rexml/document'
require 'rubygems'
require 'hpricot'


@@airtimeURL = "http://hollowearth.out.airtime.pro:8000/hollowearth_a.xspf"
#@@airtimeURL = "http://192.168.0.44:8000/airtime.mp3.xspf"
#@@airtimeURL = "http://herhq.org:8000/airtime.mp3.xspf"

class Ripper 
  
  def self.rip_one    
    if (File.exists?("/Users/garrettkelly/Library/Application\ Support/Nicecast/use_off_hours.txt")) 
	IO.popen("osascript -e 'tell application \"iTunes\" to play track 1 of user playlist \"off hours\"' ", "w+")
        p "The Off Hours File exists! Ripping off hours titles!!!!"
        xspf = @@airtimeURL
        open( xspf ) do |http|
          response = http.read
          xml = REXML::Document.new( response )
          xml.elements.each do |t|
            puts t
          end
            
          open("/Users/garrettkelly/Library/Application\ Support/Nicecast/current_title.xml", "wb") do |file|
            file.write(response)
          end
          
          begin
            @small_doc= Hpricot(response)
            #puts response
            title = ""
            @small_doc.search("title").each{ |e| title =  e.to_plain_text }
            split_title = title.split(' - ')
            artist = split_title[0]
            split_title.delete_at(0)
            song_title = split_title.join('-')
  
            p "artist #{artist}"
            p "songtitle = #{song_title}"
            p "Song: #{title}"

            open(File.expand_path("~/Library/Application\ Support/Nicecast/NowPlaying.txt"), "wb") do |file|
              file.write("Title: #{song_title}\nArtist: #{artist}\nAlbum: NOTUSED\nTime: 00:00 ")
            end
          end
        end   
    else
      p "The Off Hours File Does Not Exist. Not ripping off hours titles."
    end
  end 
end

Ripper.rip_one

