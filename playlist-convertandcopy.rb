# the plist library is used to make parsing the playlist much easier, and easier to read
require "plist"
# the open3 library is used to start the ffmpeg process, and neatly capture the output
require "open3"
# optparse makes a very pretty command line interface, and builds a dynamic help screen
require "optparse"
# the URI library parses out the characters from the playlist (%5, %20, etc)
require "URI"


#this block parses the options and stores them in the options hash
options = {}
options[:directory] = ''
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} options"
  opts.on("-l", "--playlist PLAYLIST", "Specify playlist for conversion (REQUIRED)") do |playlist|
    options[:playlist] = playlist.to_s
  end
  opts.on("-d", "--directory /target/directory", "Overrides default directory (current directory)") do |target|
    options[:target] = target.to_s
  end
end

# this block will show the help screen if no arguments are specified or if it is specified incorrectly
begin
  optparse.parse!
  mandatory = [:playlist]
  missing = mandatory.select{ |param| options[param].nil?}
  if not missing.empty?
    puts "The following options are required but not specified: #{missing.join(', ')}"
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

# Load specified PList formatted XML playlist into a more managable array
result = Plist::parse_xml(options[:playlist])

# iterates through each track in the playlist
result["Tracks"].each do |wat, value|
  # replaces the URI encoding with appropriate whitespace and characters, and fixes the path
  fily = URI.decode(value["Location"].gsub("file://localhost",""))
  # pulls the extension from the file and removes the . from it
  extension = File.extname(fily).split('.').last
  # takes out any non-word (AZ10-_) character and replaces the extension with mp3 for the target
  puts "Encoding: #{target_file = fily.split('/').last.gsub(/\W+/,'').gsub(extension,".mp3")}"
  # checks to see if the file exists... if not
  unless File.exists?(target_file)
    # reencode the file to the new name and directory
    command = "ffmpeg -i \"#{fily}\" -ab 256k #{target_file}"
    # captures output from our command
    stdin, stdout, stderr = Open3.popen3(command)
    puts stdout.readlines
    puts stderr.readlines
  else
    puts "File already exists."
  end
end