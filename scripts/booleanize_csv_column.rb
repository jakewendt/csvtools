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
	:columns => []
#	:verbose => false
}

optparse = OptionParser.new do |opts|
	# Set a banner, displayed at the top of the help screen.
	opts.banner = "\nUsage: #{File.basename($0)} [options] csv_file(s)\n\n" <<
		"This script was designed to 'booleanize' the requested columns from the given csv files.\n" <<
		"For the given columns, it finds all values, possibly multiple per record, split on ';', creates new columns for each of these values and fills them with 0 or 1.\n" <<
		"ALL CSV files MUST have the same columns.\n" <<
		"Column names are case sensitive.\n\n" <<

		"If multiple columns are specified, separate them with commas.\n\n" <<
		"If they contain spaces, it MUST be quoted ... \"col1, Column 2\".\n\n" <<
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
		"  1;2;3,4,5,1,1,1\n\n" <<
		" cat abcde.csv\n" <<
		"  a,b,c,d,e\n" <<
		"  1,1,1,1;2,3\n" <<
		"  1;2,1,1,,3\n" <<
		"  ,1,1,2,3\n" <<
		"  1;3,1,1,1;2;3,4\n" <<
		" #{File.basename($0)} -c a,d abcde.csv\n" <<
		"  a,b,c,d,e,a_1,a_2,a_3,d_1,d_2,d_3\n" <<
		"  1,1,1,1;2,3,1,0,0,1,1,0\n" <<
		"  1;2,1,1,,3,1,1,0,0,0,0\n" <<
		"  ,1,1,2,3,0,0,0,0,1,0\n" <<
		"  1;3,1,1,1;2;3,4,1,0,1,1,1,1\n\n"

	#	Define the options, and what they do

	opts.on( '-c', '--col column_name(s)', "CSV Column Names (separated by commas)") do |columns|
		options[:columns] = columns.split(/\s*,\s*/).uniq
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

column_values = {}
options[:columns].each do |column|
	column_values[column] = []
end

ARGV.each do |infilename|
	(CSV.open( infilename, 'r:bom|utf-8', headers: true )).each do |line|
		options[:columns].each do |column|
			column_values[column] += line[column].to_s.squish.split(/\s*;\s*/)
		end
	end
end

column_values.each_pair do |column,values|
	column_values[column]=values.uniq
end

column_values.each_pair do |column,values|
	values.each do |value|
		raise "#{column}_#{value} Exists" if header_line.include?("#{column}_#{value}")
		header_line << "#{column}_#{value}"
	end
end

puts header_line.to_csv
ARGV.each do |infilename|
	(CSV.open( infilename, 'r:bom|utf-8', headers: true )).each do |line|
		column_values.each_pair do |column,values|
			values.each do |value|
				line << (( line[column].to_s.squish.split(/\s*;\s*/).include?(value) ) ? 1 : 0)
			end
		end
		puts line.to_csv
	end
end

