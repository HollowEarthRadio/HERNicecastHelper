require 'cgi'
require 'open-uri'
require 'rexml/document'
require 'rubygems'
require 'hpricot'

class ITunesRipper
  def self.rip_one
    if (File.exists?("/Users/garrettkelly/Library/Application\ Support/Nicecast/use_itunes.txt"))
      p "The Use iTunes File exists! Ripping iTunes titles!!!!"
      artist_applescript = IO.popen("osascript -e 'tell application \"iTunes\" \n if player state is not stopped then \n get artist of current track \n end if \n end tell'",  "r")
      song_title_applescript = IO.popen("osascript -e 'tell application \"iTunes\" \n if player state is not stopped then \n get name of current track \n end if \n end tell'",  "r")
      artist = cleanup(artist_applescript)
      song_title = cleanup(song_title_applescript)
  
      open(File.expand_path("~/Library/Application\ Support/Nicecast/NowPlaying.txt"), "wb") do |file|
      #open(File.expand_path("~/Desktop/NowPlaying.txt"), "wb") do |file|
        file.write("Title: #{song_title}\nArtist: #{artist}\nAlbum: NOTUSED\nTime: 00:00 ")
      end
    else
      p "The Off Hours File Does Not Exist. Not ripping off hours titles."
    end
  end

  def self.cleanup(io)
    io.lines.first.gsub("\n", '')
  end
end

ITunesRipper.rip_one

