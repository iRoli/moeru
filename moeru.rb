# moeru, a simple anime episodes notifier.
# Currently unfinished, and very ugly.
# Things to complete/do:
# 1 - Creating & loading a file that contains the Marshaling data, create one if doesn't exists.
#     Add exceptions, very important.
# 2 - Command for updating all the animays, also threads.
# 3 - More atributes to AnimeProfile: @torrents downloaded which shouldn't be downloaded again, unless user specify it.
#     @error true if there was an error prior fetching the page, so the user will need to use update().
# 4 - Better exceptions: File isn't created, can't be read nor writed in. Support this in: NT | Gnu/Linux | Os X
#     The page hasn't any episode (Maybe the name and/or sub isn't correct) raise a message.
# 5 - Split this into files.
# 6 - IMPORTANT: Sanitize input, never trust user input; problems detected at: edit, update_by_id, eps_seen, 
#                Also, refactor some code, DRY, we repeat a lot, rebuild the url when edited item.
# 7 - Reorder main().
# 8 - More exceptions for the file, FUCKING REORDER MAIN, make everything prettier.
# 113 LOC
# License: nay, for_what_purposes.jpg
# Last updated: 9/12/2014
# 
require_relative 'lib/cli'
require_relative 'lib/page_threads'
require_relative 'lib/series'
require_relative 'lib/file'
require "open-uri"
require "yaml"

# Notes: page 405 marshaling, 165 opening files IO (493 file modes)

# Debug, :ON || :OFF
DEBUG = :OFF
#!= What if we want delete a field, let's say we don't need anymore the field "720p" or others?
#   After we entered it, but not needed anymore, how we delete it?
#!= What if we need to check the url builded, maybe add this only for debugging
#!= If edited fansub update!
#!= Print list by a, b, c (index), example, list a would print the animes that start with a.
#   other way, would be printing the list sorted by name A, then B, and so on. I prefer the first one.
# Options
ops = Options.new
# File for marshaling
ops.file = IOfile.exists? # ops hold true if file existed, or if it was created

series = [] # Series object, this hold all the info for the animays
index = Index.new # Index for array

if (ops.file)
    begin
        series = YAML.load(File.open("lib/db.txt"))
        index.set_at(series.length)
        puts "LENGTH IS: #{index.number}" if DEBUG == :ON
    rescue NoMethodError, ArgumentError
        puts "NoMethodError" if DEBUG == :ON
        series = []
        Action.seems_empty()
        #-! If not wanna restore, quit, or save an option at quiting to check again and save it
        if (Action.yes_or_no?) # File is corrupt, restore it
            File.open("lib/db.txt", "w+") do |f|
                YAML.dump(series, f)
            end
        end
    end
end

puts "Welcome to moeru, #{ENV['USER']} :3"
condition = 0
while condition < 5 #-! Change to infinite loop
    case Command.ask()
        # add, edit, list, update_all, update_by_id, delete, quit
        when 'add'
            series[index.number] = AddSeries.new_anime
            index.up
            condition += 1
        when 'edit'
            id = Action.ask_to_edit()
            if (id && !Sanitize.is_neg?(id) && Sanitize.in_bounds?(id, series))
                Action.edit(id, series) #-!OK, del comm if episodes changed do again the operation to re-calculate @eps_remaining
                Action.rebuild_url(id, series)
            end
        when 'list'
            List.get(series)
        when 'update_all' #!- update 5 at time
            Action.to_update_all(series)
            puts "UPDATING ALL: #{id}"
        when 'update_by_id'
            id = Action.to_update_by_id()
            if (id && !Sanitize.is_neg?(id) && Sanitize.in_bounds?(id, series))
                Action.update_one(id, series)
                puts "UPDATING: #{id}"
            puts "Eps found: #{series[id].eps_found}"
            end
        when 'delete'
            id = Action.ask_to_delete()
            if (id && !Sanitize.is_neg?(id) && Sanitize.in_bounds?(id, series))
                Action.delete(series, id)
            end
        when 'quit'
            # series.pop
            break
        else
            # index.up
            condition += 1
    end
end

begin
    if (DEBUG == :ON)
        data = YAML.dump(series)
    end
    File.open("lib/db.txt", "w+") do |f|
        YAML.dump(series, f)
    end
rescue
    puts ("Trying to save it again")
    retry
end

if (DEBUG == :ON)
    puts "Series id: #{series.object_id}, data id: #{data.object_id}"
    marobj = YAML.load(data)
    puts "marobj id: #{marobj.object_id}"
    i = 0
    series.each do
        puts "Anime: #{marobj[i].name}"
        puts "Url built:"
        puts marobj[i].builded_url
        puts "Episodes found: #{marobj[i].eps_found}"
        puts "Episodes left: #{marobj[i].eps_remaining}"
        puts
        i += 1
    end
end

puts Debug.show(series) if DEBUG == :ON