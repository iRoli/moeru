# Moeru, a simple anime episodes notifier.
# Currently unfinished, and very ugly.
# Things to complete:
# Marshaling objects into a file, creating & loading this file, proper methods to command(), indexing/ID's to the series, method to
# search a series, download every .torrent file (something to control if was downloaded and deleted), maybe split this thing into related files.
# License: nay

require "open-uri"
# Module Help
# Description: List the commands available with a simple description.
module Help
    attr_reader :list
    def get
    @list =
"Command  ----  Action
    add    -- Add new anime
    delete -- delete anime, it will ask for id
    edit   -- edit anime
    update -- will check if new episodes
    quit   -- exit"
    end
end
# End of Module Help

# Module RequestEpisodes
# Description: This module gets an array containing the list of uploaded episodes, from the html source.
#              It declares a few instance variables: @list, @eps_found, and @eps_remaining.
module RequestEpisodes
    def request_page
        begin
        source = open(@builded_url).read
        rescue
        source = nil
        puts "Exception reached"
        end
        regex = /<title>([^<]*)<\/title>/
        if (source != nil) 
            # Create array to save the list of episodes
            @list = []
            @list = source.scan(regex)
            # Flat the array, since it was [["Nya"]["Episode"]]
            @list = @list.flatten
            # When extracting the episodes, the first element of the array ALWAYS is "NyaaTorrents"
            # because is the first title tag in the rss, delete it.
            @list.shift
            @eps_found = @list.length
            @eps_remaining = @eps_found - @eps_seen
        else
            # Print a warning that couldn't reach the server
            # If there was info about the episodes after this error, keep that, if not save the error or something.
        end
    #print "Source: #{source.class}\n"
    #print "List: #{@list}"
    end
end
# End of Module RequestEpisodes

# BuildUrl -------- BEGIN OF CLASS --------
# Description: Builds an rss url of nyaa.se when given a series name and the fansubbing group.
#              Also, replaces every space/tab/newline on the parameters to a single plus sign '+'.
# Parameters: Two strings, the anime name and the sub group.
# Returns: The url builded, something like this: http://www.nyaa.se/?page=rss&cats=1_0&term=Gokukoku+no+Brynhildr+AE
class BuildUrl
    def initialize(name, subgroup, resolution)
        @name = name
        @subgroup = subgroup
        @resolution = resolution
    end
        # This method clean, will replace every space, tab, newline with a plus sign, and then two or more plus sign with just one.
    def clean
        @url = @url.gsub(/\s/, '+')
        @url = @url.gsub(/\+{2,}/, '+')
    end
    def build
        # Build the string
        @url = "http://www.nyaa.se/?page=rss&cats=1_0&term=" + @name + "+" + @subgroup + "+" + @resolution
        # Call the method clean which will clean the url, and it returns the last expression evaluated of this method clean.
        clean()
    end
end
# BuildUrl -------- END OF CLASS --------

# Method command
# Description: Ask for an action to do (command), like adding, delete, edit a series.
# Parameters: The command, a string.
# Returns: Depends on the command given, sometimes an object, other just edit that object.
def command
    include Help
    list = Help.get
    cmd_unknown = false
    loop do
        if (cmd_unknown == false)
            print "Enter cmd: "
        else
            puts "Unknown command"
            printf "Enter cmd (press ? for all the available commands): "
        end
        # Read stdin
        @cmd = String(gets.chomp)
        #Switch
        case @cmd
            when 'add'
                # Add new anime
                series = AddSeries.new.anime
                break(series)
            when 'delete'
                # Ask id/delete, delete anime
                puts "deleting anime"
                break('delete')
            when 'edit'
                # Edit anime, ask for id/name
                puts "editing anime"
                break('edit')
            when 'update'
                # Update all animays, not sure if we want to make this automatically. ;-;
                puts "updating anime"
                break('update')
            when '?', 'help', 'welp'
                # Check connection.
                # Check file.
                # Print commands.
                puts list
                break('help')
            when 'quit'
                # Quit plox
                puts "exiting...\n"
                break('quit')
            else
                # ask_again
                cmd_unknown = true
        end
    end    
end
# End of Method command

# Index -------- BEGIN OF CLASS --------
# Description: This is the index for the series object, use the method up when a new series is pushed into the array. The method
#              down is used when the object pushed into the array is not a valid AnimeProfile object (like a string for exammple).
# Parameters: --
# Returns: --
class Index
    attr_reader :number
    def initialize#(name)
        # Read Marshal file
        @number = 0
    end
    def up
        @number += 1
    end
    def down
        @number -= 1
    end
end
# Index -------- END OF CLASS --------

# GetInfo -------- BEGIN OF CLASS --------
# Description: Ask for an anime name, the subbing group, the episodes already watched, 
# Parameters: Two strings, the anime name and the sub group.
# Returns: --
class GetInfo
    def ask_anime
    print("Enter anime: ")
    @ask_anime = String(gets.chomp)
    end
    def ask_subgroup
    print("Enter subbing group: ")
    @ask_subgroup = String(gets.chomp)
    end
    def ask_resolution
    printf("Enter resolution (normally one of the following 420p|720p|1080p): ")
    @ask_resolution = String(gets.chomp)
    end
    def ask_eps_seen
    print("How many episodes of this series have you watched?: ")
    @ask_eps_seen = Integer(gets.chomp)
    end
end
# GetInfo -------- END OF CLASS --------

# AnimeProfile -------- BEGIN OF CLASS --------
# Description: This save an series profile, inluding the name series, fansubbing group, ID, builded url,
#              episodes seen, episodes found, episodes remaining.
# Parameters: --
# Returns: --
class AnimeProfile
    include RequestEpisodes
    # Accesors
    attr_reader :name, :fansub, :builded_url, :resolution, :eps_seen, :eps_found, :eps_remaining
    # Getters
    def name=(str_name)
    @name = str_name
    end
    def fansub=(str_sub)
    @fansub = str_sub
    end
    def builded_url=(str_url)
    @builded_url = str_url
    end
    def resolution=(str_res)
    @resolution = str_res
    end
    def eps_seen=(str_eps)
    @eps_seen = str_eps
    end
end
# AnimeProfile -------- END OF CLASS --------

# AddSeries
# Description: Wrapper to call every setter method to create an AnimeProfile instance.
# Parameter: --
# Returns: An object of AnimeProfile.
class AddSeries
    attr_reader :anime
    def initialize
    @anime             = AnimeProfile.new # Create a new series
    getinfo            = GetInfo.new
    @anime.name        = getinfo.ask_anime
    @anime.fansub      = getinfo.ask_subgroup
    @anime.resolution  = getinfo.ask_resolution
    @anime.builded_url = BuildUrl.new(anime.name, anime.fansub, anime.resolution).build # Build url
    @anime.eps_seen    = getinfo.ask_eps_seen
    @anime.request_page
    end
end
# AddSeries -------- END OF CLASS --------
=begin
anime = AddSeries.new.anime
# stdout
puts ("\n")
#puts anime.name
#puts anime.fansub
puts "Url built:"
puts anime.builded_url
#puts anime.eps_seen
puts "Episodes found: #{anime.eps_found}"
puts "Episodes left: #{anime.eps_remaining}"
=end
puts "Welcome to moeru :3"
series = []
condition = 0
index = Index.new # Index for array

while condition < 3
    series[index.number] = command()
    case series[index.number]
        when 'delete', 'edit', 'update', 'help'
            # Do nothing, improve this, is ugly.
        when 'quit'
            series.pop
            break
        else
            index.up
            condition += 1
    end
end

#p series
i = 0
series.each do
    puts "Anime: #{series[i].name}"
    puts "Url built:"
    puts series[i].builded_url
    puts "Episodes found: #{series[i].eps_found}"
    puts "Episodes left: #{series[i].eps_remaining}"
    puts
    i += 1
end
