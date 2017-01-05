#!/usr/bin/env ruby

require 'csv'



if ARGV.length <= 0
	puts
	puts "#{$0} <CSV_FILE_NAMES>"
	puts
	puts "This script reads the header (first line) of each of the given csv files."
	puts "This list of columns is then merged and uniqued."
	puts "Then each file is read and each column from the complete list is printed."
	puts "If the current file does not have a given column, it is left blank."
	puts "In addition, it adds a column called filename and includes this data with each row."
	puts "The output can, if desired, be redirected to a file."
	puts
	puts "Examples:"
	puts "	cat abc.csv"
	puts "	a,b,c"
	puts "	1,2,3"
	puts "	4,5,6"
	puts
	puts "	cat bcd.csv"
	puts "	b,c,d"
	puts "	7,8,9"
	puts "	10,11,12"
	puts
	puts "	bin/merge_csvs.rb abc.csv bcd.csv"
	puts "	filename,a,b,c,d"
	puts "	abc.csv,1,2,3,"
	puts "	abc.csv,4,5,6,"
	puts "	bcd.csv,,7,8,9"
	puts "	bcd.csv,,10,11,12"
	puts
	puts "	#{$0} dots*other-specify-data.csv > merged-other-specify-data.csv"
	puts "	#{$0} dots*other-specify-data*1*.csv > merged-other-specify-data\(1\).csv"
	puts "	#{$0} dots*alter-pair-data.csv > merged-alter-pair-data.csv"
	puts "	#{$0} dots*ego-alter-data.csv > merged-ego-alter-data.csv"
	puts

	exit
end



all_columns=[]

ARGV.each do |infilename|
#	puts infilename

#	:bom|utf-8 NEEDED for screening data, but don't cause issues in others, so keep it.
#	This also removes double quotes from fields unless needed
#	CSV.open( infilename, 'r:bom|utf-8', headers: true, return_headers: true ).each do |incsv|
#		CSV.open( "#{infilename}.psv", 'a', col_sep: '|') do |csv|
#			csv << incsv
#		end
#	end

	f=CSV.open( infilename, 'rb')
	header_line = f.gets
	f.close
	all_columns += header_line

end

all_uniq_columns = all_columns.uniq
puts (['filename']+all_uniq_columns).to_csv

ARGV.each do |infilename|
	(CSV.open( infilename, 'r:bom|utf-8', headers: true )).each do |line|
		puts ([infilename] + all_uniq_columns.collect{|c|line[c]}).to_csv
	end
end

