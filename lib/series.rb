# Series Profile; basically the series objects.
# Last updated: 9/12/2014

# Note: This file requires some modules of other files (cli.rb & page_threads.rb), but since moeru.rb also includes it (on top) it's unnecessary
#       to add it here; missing PHP's require_once(). 
# require_relative 'cli'
# require_relative 'page_threads'

# 92 LOC
# BuildUrl -------- BEGIN OF CLASS --------
# Description: Builds an rss url of nyaa.se when given a series name and the fansubbing group.
#              Also, replaces every space/tab/newline on the parameters to a single plus sign '+'.
# Parameters: Three strings, the anime name, the sub group, and the resolution.
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

# AnimeProfile -------- BEGIN OF CLASS --------
# Description: This save an series profile, inluding the name series, fansubbing group, ID, builded url,
#              episodes seen, episodes found, episodes remaining.
# Parameters: --
# Returns: --
class AnimeProfile < RequestEpisodes
    #include RequestEpisodes
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
module AddSeries
    include GetInfo
    def AddSeries.new_anime
    anime             = AnimeProfile.new # Create a new series
    anime.name        = GetInfo.ask_anime
    anime.fansub      = GetInfo.ask_subgroup
    anime.resolution  = GetInfo.ask_resolution
    anime.builded_url = BuildUrl.new(anime.name, anime.fansub, anime.resolution).build # Build url
    anime.eps_seen    = GetInfo.ask_eps_seen
    anime.request_page
    return anime
    end
end
# End of Module AddSeries

# Debug
# Description: Prints the object's info to stdout
# Parameter: Series object
# Returns: Nothing, only prints data
module Debug
    def Debug.show(series)
        puts("#!DEBUGGING:")
        List.get(series)
    end
end