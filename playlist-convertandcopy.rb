require "plist"
require "open3"

result = Plist::parse_xml("Dubstep Goodies.xml")
result["Tracks"].each do |wat, value|
  fily = value["Location"].gsub("file://localhost","").gsub("%20"," ").gsub("%5B","[").gsub("%5D","]")
  extension = value["Location"].gsub("file://localhost","").gsub("%20"," ").gsub("%5B","[").gsub("%5D","]").split('.').last
  puts target_file = fily.split('/').last.gsub(extension,"mp3").gsub(" ","").gsub("/","").gsub("(","").gsub(")","").gsub("!","").gsub("?","").gsub("&","and")
  unless File.exists?(target_file)
    puts command = "ffmpeg -i \"#{fily}\" -ab 256k #{target_file}"
    stdin, stdout, stderr = Open3.popen3(command)
    puts stdout.readlines
    puts stderr.readlines
  else
    puts "File already exists."
  end
end
