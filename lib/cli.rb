# Command Line Interface for moeru
# Methods and modules that ask for data from the stdin (sanitized) and also prints data.
# Last updated: 9/12/2014

# 241 LOC
# Module Help
# Description: List the commands available with a simple description.
module Help
    def Help.get
        list =
"   Command  ----  Action
      add    -- Add new anime
      edit   -- edit anime
      list   -- prints the list of animes and corresponding ID
              which is used to edit them
  update_all -- check if new episodes in all the series
update_by_id -- check if new episodes on only that ID's series,
              it will ask for id
      delete -- delete anime, it will ask for id
      quit   -- exit"
    return list
    end
end
# End of Module Help

# Module GetInfo
# Description: Ask for an anime name, the subbing group, the episodes already watched
module GetInfo
    def GetInfo.ask_anime
    print("Enter anime: ")
    return String(gets.chomp)
    end
    def GetInfo.ask_subgroup
    print("Enter subbing group: ")
    return String(gets.chomp)
    end
    def GetInfo.ask_resolution
    printf("Enter resolution (normally one of the following 420p|720p|1080p): ")
    return String(gets.chomp)
    end
    def GetInfo.ask_eps_seen
    print("How many episodes of this series have you watched?: ")
    eps = Integer(gets.chomp) rescue nil
    puts "Eps input is #{eps}" if DEBUG == :ON
    if (Sanitize.is_nil?(eps) || Sanitize.is_neg?(eps))
        return 0
    else
        return eps
    end
    end
end
# End of Module GetInfo

# Module Command
# Description: Ask for an action to do (command), like adding, delete, edit a series.
# Parameters: --
# Returns: A string containing the command.
module Command
    include Help
    def Command.ask
        list = Help.get
        cmd_unknown = false
        # add, edit, list, update, delete, quit
        loop do
            if (cmd_unknown == false)
                print "Enter cmd: "
            else
                puts "Unknown command"
                printf "Enter cmd (press ? for all the available commands): "
            end
            # Read stdin
            cmd = String(gets.chomp)
            #Switch
            case cmd
                when 'add'
                    # Add new anime
                    break('add')
                when 'edit'
                    # Edit anime, ask for id/name
                    puts "editing anime"
                    break('edit')
                when 'list'
                    break('list')
                when 'update_all'
                    # Update all animays, not sure if we want to make this automatically. ;-;
                    puts "updating all anime"
                    break('update_all')
                when 'update_by_id'
                    # Update all animays, not sure if we want to make this automatically. ;-;
                    puts "updating by id"
                    break('update_by_id')
                when 'delete'
                    # JUST ask for deleting command
                    puts "deleting anime"
                    break('delete')
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
end
# End of Module Command

# Module Actions
# Description: Ask for an ID, validating it. Serves to commands like: delete(), update_all(), update_by_id()
#              Also, Action.delete(), deletes a series at the given id.
# Parameters: The array of series to Action.to_update_all() and Action.delete(), and the id too for Action.delete()
# Returns: An integer or nil if the input wasn't proper.
module Action
    def Action.ask_to_delete
        print("Enter id to delete (n to cancel): ")
        id = gets.chomp
        id = Integer(id) rescue nil
        return id
    end
    def Action.ask_to_edit
        print("Enter id to edit (n to cancel): ")
        id = gets.chomp
        id = Integer(id) rescue nil
        return id
    end
    def Action.edit(id, series)
        puts("Enter . (point) to leave field unchanged")
        print("Edit name, now is \"#{series[id].name}\": ")
        current = Action.get_string()
        if (!Sanitize.leave_unchanged?(current))
            series[id].name = current
        end
        print("Edit fansub, now is \"#{series[id].fansub}\": ")
        current = Action.get_string()
        if (!Sanitize.leave_unchanged?(current))
            series[id].fansub = current
        end
        print("Edit resolution, now is \"#{series[id].resolution}\": ")
        current = Action.get_string()
        if (!Sanitize.leave_unchanged?(current))
            series[id].resolution = current
        end
        print("Edit Episodes seen, now is \"#{series[id].eps_seen}\": ")
        current = Action.get_id()
        if (!Sanitize.leave_unchanged?(current) && !Sanitize.is_neg?(current))
            series[id].eps_seen = current
            series[id].rem_eps() # update eps remaining
        end
    end
    def Action.rebuild_url(id, series)
        series[id].builded_url = BuildUrl.new(series[id].name, series[id].fansub, series[id].resolution).build
    end
    def Action.to_update_all(series)
        if (series.length != 0)
	    series.each do |animay|
	        animay.request_page()
	    end
	end
    end
    def Action.update_one(id, series)
        series[id].request_page()
    end
    def Action.to_update_by_id
        print("Enter id to search for new episodes: ")
        id = gets.chomp
        id = Integer(id) rescue nil
        return id
    end
    def Action.delete(series, at_id)
        if (at_id != nil)
            series.delete_at(at_id)
        end
    end
    def Action.get_string()
        return String(gets.chomp)
    end
    def Action.get_id()
        return Integer(gets.chomp) rescue nil
    end
    def Action.yes_or_no?()
        print("Do you want to restore db file? This will delete all the info in the file!\n" +
                "Press y or n: ")
        response = String(gets.chomp) rescue nil
        if (!response || !response == "" || response == "no" || response == "n")
            return false
        else
            return true
        end
    end
    def Action.seems_empty()
        puts "File seems empty"
    end
end
# End of Module Actions

# Module Sanitize
# Description: Methods to sanitize user input, like checking if the id given is inside of
#              object's bounds, if number is negative, nil, etc.
# Parameters: The input given, id (int).
# Returns: Sanitized input, nil if input was wrong.
module Sanitize
    def Sanitize.is_nil?(foo)
        if (foo == nil)
            return true
        else
            return false
        end
    end
    def Sanitize.in_bounds?(id, series)
        if (id < series.length)
            return id
        else
            return nil
        end
    end
    def Sanitize.leave_unchanged?(str)
        if (str == "." || str == nil || str == "")
            return true
        else
            return false
        end
    end
    def Sanitize.is_neg?(id)
        if (id == nil)
            return true
        elsif (id < 0)
            return true
        else
            return false
        end
    end
end
# End of Module Sanitize

# Module List
# Description: Prints all the series name and the id, and get_all_ids() return the number of series.
# Parameters: The arrays of series.
# Returns: List.get only prints to the stdout, List.get_all_ids() an integer.
module List
    def List.get(series)
        if (series.length != 0)
            series.each.with_index do |anime, id|
                puts "Anime: #{anime.name}\nID: #{id}, Eps Seen: #{anime.eps_seen}," +
                " Eps Found: #{anime.eps_found}, Eps Left: #{anime.eps_remaining}," +
                " Fansub: #{anime.fansub}"
                puts "Object ID: #{anime.object_id}" if DEBUG == :ON
                puts "URL: #{anime.builded_url}" if DEBUG == :ON
            end
        else
            puts "List is empty"
        end
        puts series.object_id if DEBUG == :ON
        puts "Series length: #{series.length}" if DEBUG == :ON
    end
    def List.get_all_ids
        series.length
    end
end
# End of Module List