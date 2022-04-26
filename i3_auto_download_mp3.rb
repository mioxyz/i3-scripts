#!/bin/ruby
require_relative 'i3_wrapper'
require 'colorize'

def format_sensible_youtube title
   index_start = title.index "("
   index_end   = title.index ")"

   if index_start and index_end then
      if 1 + index_end == title.length then
         title = title[0, index_start ]
      else
         title = title[0, index_start ] + "_" + title[index_end + 1, title.length ]
      end
   end

   return title.gsub("  ", " ")
               .split(" ")
               .map{ |word| word.capitalize }
               .join()
               .gsub(/\p{^Alnum}/, ''); #TODO ignore underscore character
end

def format_sensible_soundcloud title
   if title.length  > 16 then
      title = title[ 0, title.length - 16 ];
   end
  return title.gsub(/[ \?"':;,.!{}()\[\]#$^&*@\\\/|+]/, "_");
end


def soundcloud_notify url
   elems = url.split("/");
   idx = elems.index( "soundcloud.com")
   if idx and ((idx + 2) < elems.length) then
      notify("yt-dlp off blast! (soundcloud)\n\n" + elems[idx+1] + "\n\n" + elems[idx+2].split("?")[0].gsub(/[-]/, " "));
   else
      notify('yt-dlp off blast! (soundcloud)');
   end
end

# https://soundcloud.com/dboydchipmusic/out-there-somewhere?utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing

dir_music = "#{%x(echo $HOME).chomp}/Music/ytmp3"
tmp_filepath_outp = "/tmp/ytmp3_youtube_dl_outp.txt"

%x[mkdir -p #{dir_music}]

clip = %x(xclip -o -selection clipboalrd)

isSoundcloud = clip[0..23].include?("soundcloud.com");

if isSoundcloud then
   soundcloud_notify(clip);
else
   notify 'yt-dlp off blast! (generic)'
end


puts "attempting to run youtube-dl on clipboard...".green
puts "clip: »".green + clip.red + "«".green

%x(touch #{tmp_filepath_outp})
# you can also split stdout and stderr with ruby and handle it over here, I forgot..
%x(cd "#{dir_music}"; yt-dlp -x --audio-format mp3 '#{clip}' > #{tmp_filepath_outp} 2>&1)
outp = File.read(tmp_filepath_outp)
outp_split = outp.split "\n"
#outp = "stuff\nstufsd\n[ExtractAudio] Destination: Why am I anxious [GbmP2c6TGKc].mp3\n"
maybe = outp_split.find{ |line| line.include?("[ExtractAudio] Destination: ") }
if maybe then
   title = ""
   title_new = ""
   if isSoundcloud then
      title = maybe[28, maybe.length];
      title_new = format_sensible_soundcloud(title)
   else
      title = maybe[28, maybe.length - (18+28)]
      title_new = format_sensible_youtube(title)
   end
   filename_old = maybe[28, maybe.length].chomp
   filename_new = title_new + ".mp3"
   puts "current filename is: ".yellow + filename_old.red + "«".yellow
   puts "title seems to be »".yellow   + title.red        + "«".yellow
   puts "renaming to: »".yellow        + filename_new.red + "«".yellow
   %x(mv "#{dir_music}/#{filename_old}" "#{dir_music}/#{filename_new}")
   notify "download completed:\n\n       #{filename_new}"
else
   puts "ERROR couldn't get title."
   maybe_error = outp_split.find{ |line| line.include?("ERROR: ") }
   if maybe_error then
      puts "yt-dlp exited with an error: »".yellow + maybe_error.red + "«".yellow
      notify "ah shit: »#{maybe_error}«"
   else
      puts "... for unknown reasons.".red
   end

end

puts "done.".green
