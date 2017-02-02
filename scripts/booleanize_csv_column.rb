#!/usr/bin/env ruby

require 'csv'
require 'optparse'

class String
	def squish
		dup.squish!
	end
	def squish!
		gsub!(/\A[[:space:]]+/, '')
		gsub!(/[[:space:]]+\z/, '')
		gsub!(/[[:space:]]+/, ' ')
		self
	end
end

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {
#	:verbose => false
}

optparse = OptionParser.new do |opts|
	# Set a banner, displayed at the top of the help screen.
	opts.banner = "\nUsage: #{File.basename($0)} [options] csv_file(s)\n\n" <<
		"This script was designed to 'booleanize' the requested column from the given csv files.\n" <<
		"For the given column, it finds all values, possibly multiple per record, split on ';', creates new columns for each of these values and fills them with 0 or 1.\n" <<
		"ALL CSV files MUST have the same columns.\n" <<
		"Column names are case sensitive.\n\n" <<
		"Examples\n\n" <<
		"#{File.basename($0)} -c RACE \"Exports 161214/merged-ego-alter-data.csv\"\n\n" <<
		" cat def.csv\n" <<
		"  d,e,f\n" <<
		"  1;2,3,4\n" <<
		"  ,3,4\n" <<
		"  2,3,4\n" <<
		"  1;2;3,4,5\n\n" <<
		" #{File.basename($0)} -c d def.csv\n" <<
		"  d,e,f,d_1,d_2,d_3\n" <<
		"  1;2,3,4,1,1,0\n" <<
		"  ,3,4,0,0,0\n" <<
		"  2,3,4,0,1,0\n" <<
		"  1;2;3,4,5,1,1,1\n\n"

	#	Define the options, and what they do

	opts.on( '-c', '--col column_name', "CSV Column") do |column|
		options[:column] = column
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


#       file required
if ARGV.empty?
	puts optparse   #       Basically display the command line help
	exit
end


f=CSV.open( ARGV[0], 'rb')
header_line = f.gets
f.close

values = []

ARGV.each do |infilename|
	(CSV.open( infilename, 'r:bom|utf-8', headers: true )).each do |line|
		values << line[options[:column]].to_s.squish.split(/\s*;\s*/)
	end
end

values = values.flatten.sort.uniq
#puts values

values.each do |v|
	raise "#{options[:column]}_#{v} Exists" if header_line.include?("#{options[:column]}_#{v}")
	header_line << "#{options[:column]}_#{v}"
end

puts header_line.to_csv
ARGV.each do |infilename|
	(CSV.open( infilename, 'r:bom|utf-8', headers: true )).each do |line|

		values.each do |v|
			line << (( line[options[:column]].to_s.squish.split(/\s*;\s*/).include?(v) ) ? 1 : 0)
		end
		puts line.to_csv
	end
end




