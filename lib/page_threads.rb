# Html source downloader.
# Downloads the page from a builded url.
# Last updated: 07/12/2014
# 86 LOC

# Module ThreadEpisodes
# TODO
# 1 This needs exceptions
# 2 Update all the series, maybe some at time, we wouldn't want havin' 100 "threads" making http request.
module ThreadEpisodes
    def ThreadEpisodes.update_all(series)
        thread = series.map.with_index do |page, index|
            Thread.new(page) do |url|
                source[index] = open(url) {|html| html.read}
                print "#{source[index]}\n"
                print "END OF HTML\n"
            end
        end
    end
end
# End of Module ThreadEpisodes

# Module GetSource
# Desciption: This module serves to get the html source, checking if the page was downloaded properly.
module GetSource
    def GetSource.load_page(builded_url)
        begin
            source = open(builded_url) {|html| html.read}
        rescue
            source = nil
            puts "Page can't be fetched"
        end
    end
end
# End of Module GetSource

# Class RequestEpisodes
# Description: This Class gets an array containing the list of uploaded episodes from the html source.
#              @list contains a list of torrent urls, @eps_found is the quantity of eps found in the webpage
#              @eps_remaining is the number of episodes that we haven't watched
#              It declares a few instance variables: @list, @eps_found, and @eps_remaining.
# Parameters: --
# Returns: --
class RequestEpisodes
    include GetSource
    def request_page
        source = GetSource.load_page(@builded_url)
        regex = /<title>([^<]*)<\/title>/
        #-! When anime is created, if page wasn't fetched @list is not created, and other Eps Left is empty.
        if (source != nil)
            # Create array to save the list of episodes
            @list = []
            @list = source.scan(regex)
            # Flat the array, since it was [["Nya"]["Episode"]]
            @list = @list.flatten
            # When extracting the episodes, the first element of the array ALWAYS is "NyaaTorrents"
            # because is the first title tag in the rss, delete it.
            @list.shift
            puts "list.length: #{@list.length}" if DEBUG == :ON
            @eps_found = @list.length
            puts "@eps_found: #{@eps_found}" if DEBUG == :ON
            rem_eps()
        end
    print "List: #{@list}" if DEBUG == :ON
    end
    def update_all(index) #with threads and shit
    
    end
    def rem_eps
        @eps_remaining = @eps_found - @eps_seen
    end

end
# RequestEpisodes -------- END OF CLASS --------