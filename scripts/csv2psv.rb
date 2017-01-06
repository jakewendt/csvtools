#!/usr/bin/env ruby

#	Ultimately, this should all be done in one script.



#	csv_prepare_for_bulk_insert.awk may just work



#	possibly_malformed_csv_to_differently_malformed_psv_for_bulk_insert.rb
#	It just rolls off the tongue.

#	"1234123d1234nka","asdf2134123412w","1341234","jimgi","MALE "A"","1/26/2014","13 DERICK AVE, Apt 1","LAS VEGAS","NV","89102","1234123412",2211,blah,yasdf,",",""",""",,"","1/6/1975","CENTENNIAL ""HILLS"" HOSPITAL NICU","900 N RANGO DRIVE"

#	Some of these "fixes" are guesses. Its malformed so no way to know "correct" fix.
#	"MALE "A"" could mean "MALE ","" or "MALE ""A"""

#	,"", - pointless empty field - remove them first 's/,"",/,,/g'

#	A"", - Malformed, add another quote (guess) - 's/\([^"]\)"",/\1""",/g'

#	 "A  - Malformed, add another quote (guess) - 's/\([^",]\)"\([^",^M]\)/\1""\2/g'

#	sed -e 's/,"",/,,/g' -e 's/\([^"]\)"",/\1""",/g' -e 's/\([^",]\)"\([^",^M]\)/\1""\2/g' test.csv 


require 'csv'
ARGV.each do |infilename|
	puts infilename
#	:bom|utf-8 NEEDED for screening data, but don't cause issues in others, so keep it.
#	This also removes double quotes from fields unless needed
	CSV.open( infilename, 'r:bom|utf-8', headers: true, return_headers: true ).each do |incsv|
		CSV.open( "#{infilename}.psv", 'a', col_sep: '|') do |csv|
			csv << incsv
		end
	end
end


#	1234123d1234nka|asdf2134123412w|1341234|jimgi|"MALE ""A"""|1/26/2014|13 DERICK AVE, Apt 1|LAS VEGAS|NV|89102|1234123412|2211|blah|yasdf|,|""","""|||1/6/1975|"CENTENNIAL ""HILLS"" HOSPITAL NICU"|900 N RANGO DRIVE

#	split on the pipe and remove any wrapping double quotes

#	remove any double double quotes

#	sed -e 's/|"\([^|]*\)"/|\1/g' -e 's/""/"/g'


#	This in another malformed csv, but bulk insert is a simple tool.
#	It simply splits on the field separator and inserts the results.
#	It doesn't really care, which is why I'm here in the first place.
#	Below is a valid bulk insert psv file.

#	Alternatively, we could use a "format file", but that will REQUIRE consistency.
#	FYI, a format file is more strict than my csv parser so wouldn't help in the beginning.

#	Or even insert the double quotes and remove them in the database.
#	UPDATE dbo.concepts
#		SET description = SUBSTRING ( description, 2, LEN(description)-2 )
#		WHERE description LIKE '"%"';
#	UPDATE dbo.concepts
#		SET description = REPLACE(description, '""', '"')
#		WHERE description LIKE '%""%';

#	Or, manually insert each parsed record one at a time.

#	1234123d1234nka|asdf2134123412w|1341234|jimgi|MALE "A"|1/26/2014|13 DERICK AVE, Apt 1|LAS VEGAS|NV|89102|1234123412|2211|blah|yasdf|,|","|||1/6/1975|CENTENNIAL "HILLS" HOSPITAL NICU|900 N RANGO DRIVE
#	1234123d1234nka|asdf2134123412w|1341234|jimgi|MALE "A"|1/26/2014|13 DERICK AVE, Apt 1|LAS VEGAS|NV|89102|1234123412|2211|blah|yasdf|,|","|||1/6/1975|CENTENNIAL "HILLS" HOSPITAL NICU|900 N RANGO DRIVE
#	1234123d1234nka|asdf2134123412w|1341234|jimgi|MALE "A"|1/26/2014|13 DERICK AVE, Apt 1|LAS VEGAS|NV|89102|1234123412|2211|blah|yasdf|,|","|||1/6/1975|CENTENNIAL "HILLS" HOSPITAL NICU|900 N RANGO DRIVE
#	1234123d1234nka|asdf2134123412w|1341234|jimgi|MALE "A"|1/26/2014|13 DERICK AVE, Apt 1|LAS VEGAS|NV|89102|1234123412|2211|blah|yasdf|,|","|||1/6/1975|CENTENNIAL "HILLS" HOSPITAL NICU|900 N RANGO " DRIVE

