#!/usr/bin/env ruby

require 'csv'
require 'optparse'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {
	:columns => [],
#	:verbose => false
}

optparse = OptionParser.new do |opts|
	# Set a banner, displayed at the top of the help screen.
	opts.banner = "\nUsage: #{File.basename($0)} [options] csv_file(s)\n\n" <<
		"This script was designed to display the requested column(s) from the given csv files.\n" <<
		"Requesting a nonexistant column will simply create an empty output column." <<
		"Column names are case sensitive." <<
		"Ex." <<
		"#{File.basename($0)} -c RACE -c RACE_-4 -c RACE_1 -c RACE_2 -c RACE_5 -c RACE_6 -c RACE_8 -c RACE_9 merged-ego-alter-data-test.csv"


	#	Define the options, and what they do

	opts.on( '-c', '--col column_name', "CSV Column") do |column|
		options[:columns] << column
	end

#	opts.on( '-v', '--verbose', 'Output more information' ) do
#		options[:verbose] = true
#	end

	# This displays the help screen, all programs are assumed to have this option.
	#	Add extra "\n" to last option for aesthetics.
	opts.on( '-h', '--help', 'Display this help screen',"\n") do
		puts opts
		exit
	end
end
 
# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!


puts options[:columns].to_csv

ARGV.each do |infilename|

	(CSV.open( infilename, 'r:bom|utf-8', headers: true )).each do |line|
		
		puts options[:columns].collect{|c|line[c]}.to_csv
		
	end

end
