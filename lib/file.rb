# This manage the file database to Marshaling the object and save the state
# Todo:
# 1 - Check if file exists, load the marshaling data. If not create one, if we couldn't create one warn and run locally object.
# 2 - Needs a lot of exceptions.
# 3 - When quiting save data, if couldn't be saved leave the file like it was before.
# Last updated: 07/12/2014

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
    def set_at(number)
        @number = number
    end
end
# Index -------- END OF CLASS --------

# Options -------- BEGIN OF CLASS --------
# Description: Used for setting the optins of the program, like running without a file to save data. We'll add more options later.
# Parameters: --
# Returns: --
class Options
    attr_accessor :file
	def initialize
        @file = false
	end
end
# Options -------- END OF CLASS --------

# Search -------- BEGIN OF CLASS --------
# Description: Search for a series, given an id or a name.
# Parameters: id or name.
# Returns: --
class Search
    def by_id(id)
        # search by id
    end
    def by_name(name)
        # search by name
    end

end
# Search -------- END OF CLASS --------

# IOfile -------- BEGIN OF CLASS --------
# Descriptopn: Check if there's a file on this current path, open it.
# Parameters: --
# Returns: --
module IOfile
    def IOfile.exists?
        if (File.exists?('lib/db.txt') && File.readable?('lib/db.txt') && File.writable?('lib/db.txt'))
            puts "File exists!" if DEBUG == :ON
	    return true;
        else
            puts "File doesn't exists"
	    bol = Action.ask_file()
	    #if we want to create file, and file was created succesfully return true
	    # else return false, and run object locally
        end
    end
    def IOfile.create
    end
end

# IOfile -------- END OF CLASS --------

# CreateFile -------- BEGIN OF CLASS --------
# Description: Creates a file to save the marshaling data.
# Parameters: --
# Returns: --
class CreateFile
end
# CreateFile -------- END OF CLASS --------