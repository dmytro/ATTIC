# @title Uliska Parsers Architecture Overview


Uliska Parsers Architecture Overview
------------------------------------

Parser consists of main class Uliska::Parser loaded from
lib/uliska_parser.rb file and loaded on demand extensions for the
class.

Each loaded on demand file should contain one or more methods named
parse_<NAME>. `uliska_parser.rb` file contains method called `parse`,
which when called greps for /^parse_/ in the list of instance methods
and call them one by one.

Each parse_<NAME> method should return parsed data only. Data returned
by each parse_* method are then assigned to the instance variable
@data (Hash) with a key `<NAME>.to_sym`. If method does not return
data (return nil or false), nothing happens.

`parse` method maintains instance variable @parsed, of already called
methods, to guarantee that no parsers are called more than once.

Raw, unparsed data are stored in instance variable @raw, parsed data
are returned in @data variable.

Instance of Uliska::Parser also contains 

### Loading files on demand

Parsing starts from loading lib/uliska_parser/generic.rb file,
containing parsers mainly for `uname` command and commands common for
all variants of UNI/Linux systems.

As parsing of YAML data progresses, more information are
collected. Uliska::Parser can then load additional files containing
more specific parsers and run Uliska::Parser.parse again and again.

For example, after first generic parsers are completed, information
about UNIX variant is known and more files can be loaded: files
containing parsers for command specific to the kernel name
(.../solaris.rb, .../linux.rb etc). After these even more specific
files are loaded, containing version number of the kernel (major and
minor): linux_2.rb, solaris_5_19.rb.

Files are loaded by Uliska::Parser.try_file method, which requires
file only if it exists and silently ignores missing files.

Additionally files can contain logic to load more files with
parsers. For example, linux.rb file, can then call loading of files
`linux/debian.rb` or `linux/redhat.rb`. And so on.
