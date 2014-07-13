# BuildUrl -------- BEGIN OF CLASS --------
# Description: Builds an rss url of nyaa.se when given a series name and the fansubbing group.
#              Also, replaces every space/tab/newline on the parameters to a single plus sign '+'.
# Parameters: Two strings, the anime name and the sub group.
# Returns: The url builded, something like this: http://www.nyaa.se/?page=rss&cats=1_0&term=Gokukoku+no+Brynhildr+AE
class BuildUrl
    def initialize(name, subgroup)
        @name = name
        @subgroup = subgroup
    end
        # This method clean, will replace every space, tab, newline with a plus sign, and then two or more plus sign with just one.
    def clean
        #@url = @url.gsub(/\t/, '+')
        #@url = @url.gsub(' ', '+')
        @url = @url.gsub(/\s/, '+')
        @url = @url.gsub(/\+{2,}/, '+')
    end
    def build
        # Build the string
        @url = "http://www.nyaa.se/?page=rss&cats=1_0&term=" + @name + "+" + @subgroup
        # Call the method clean which will clean the url, and it returns the last expression evaluated of this method clean.
        clean
    end
end
# BuildUrl -------- END OF CLASS --------

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
    def ask_eps_seen
    print("How many episodes of this series have you watched?: ")
    @ask_eps_seen = Integer(gets.chomp)
    end
    #This gets the currently available episodes
    def get_uploaded_eps
    # Magic...
    12
    end
end
# GetInfo -------- END OF CLASS --------

# AnimeProfile -------- BEGIN OF CLASS --------
# Description: This save an series profile, inluding the name series, fansubbing group, ID, builded url,
#              episodes seen, episodes found, episodes remainding.
# Parameters: --
# Returns: --
class AnimeProfile
    # Accesors
    attr_reader :name, :fansub, :builded_url, :eps_seen, :eps_found
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
    def eps_seen=(str_eps)
    @eps_seen = str_eps
    end
    def eps_found=(str_epsfd)
    @eps_found = str_epsfd
    end
    def eps_remainding
    @eps_remainding = @eps_found - @eps_seen
    end
end
# AnimeProfile -------- END OF CLASS --------


anime = AnimeProfile.new
first_anime = GetInfo.new # Ask for the animay
anime.name = first_anime.ask_anime
anime.fansub = first_anime.ask_subgroup
anime.builded_url = BuildUrl.new(anime.name, anime.fansub).build # Build url
anime.eps_seen = first_anime.ask_eps_seen
anime.eps_found = first_anime.get_uploaded_eps


# stdout
puts ("\n")
#puts anime.name
#puts anime.fansub
puts "Url builded:"
puts anime.builded_url
#puts anime.eps_seen
#puts anime.eps_found
#puts anime.eps_remainding