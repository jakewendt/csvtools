#!/usr/bin/env ruby
require 'csv'
ARGV.each do |infilename|
	puts infilename
	CSV.open( infilename, 'r', col_sep: '|', headers: true, return_headers: true ).each do |incsv|
		CSV.open( "#{infilename}.csv", 'a', col_sep: ',') do |csv|
			csv << incsv
		end
	end
end
