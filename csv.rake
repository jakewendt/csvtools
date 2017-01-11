require 'csv'
namespace :csv do

	task :split => :environment do
#puts `pwd`
#	interesting that even if run from other than rails root, it will chdir to rails root
		env_required('csv_file')
		file_required(ENV['csv_file'])
		
		root_extname  = File.extname(ENV['csv_file'])
		root_filename = File.basename(ENV['csv_file'],root_extname)

		f=CSV.open( ENV['csv_file'], 'rb:bom|utf-8')	#	bom just in case from Janice
#
#	each_slice doesn't seem to work right for CSV
#	using File will mean that if there are broken lines, this will fail
#
#		f=File.open( ENV['csv_file'], 'rb:bom|utf-8')	#	bom just in case from Janice
		header_line = f.gets
		slice_counter = 0
		f.each_slice(25) do |slice|
			slice_counter += 1
			outfilename = "#{root_filename}_#{sprintf("%02d",slice_counter)}#{root_extname}"
			File.open(outfilename,'w') do |f| 
				f.puts header_line.to_csv
				slice.each { |row| f.puts row.to_csv }
#				f.puts slice	#	slice is array of arrays, which when puts'd create a long list
			end
		end
		f.close
	end

	desc "Show given columns values in each row of csv file"
	task :show_column_values => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])
		env_required('columns','is required comma separated list')
		columns = ENV['columns'].split(/\s*,\s*/)

		f=CSV.open( ENV['csv_file'], 'rb')
		header_line = f.gets
		f.close

		columns.each do |c|
			unless header_line.include?(c)
				puts
				puts "'#{c}' is not a valid column"
				puts "Columns are #{header_line.join(', ')}"
				puts
				exit(1)
			end
		end

		columns_hash = {}

		(f=CSV.open( ENV['csv_file'], 'rb',{
				:headers => true })).each do |line|
#			columns.each { |c| printf("%s\t",line[c]) }
			columns.each do |column|
				columns_hash[column] ||= {}
				if columns_hash[column].has_key?(line[column])
					columns_hash[column][line[column]] += 1
				else
					columns_hash[column][line[column]] = 1
				end
			end	#	columns.each do |column|
		end	#	(f=CSV.open( ENV['csv_file'], 'rb',{
		columns.each do |column|
			puts column
			columns_hash[column].each do |k,v|
				puts "   :#{k}:#{v}"
			end
			puts
		end
	end	#	task :show_column_values => :environment do

	desc "Show ALL columns values with counts in each row of csv file"
	task :show_all_column_values => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])
		columns_hash = {}.with_indifferent_access
		ignore_columns = (ENV['ignore']||'id,childid').split(/,/)
ignore_columns += %w( att16 bma3 bmb3 cbf7 cbf7_old cim4 )
ignore_columns += %w( createdate cy3 cy3_legacy cy4 fc1m fsh_hospresults )
ignore_columns += %w( id1 id2 id3 id4 id5 id6 id7 id8 )
ignore_columns += %w( fc1b hs2 pe12a bm1b_7 bm1b_28 bm1b_14 fc1b_14 )
ignore_columns += %w( nd4b cbc2 pe2 cbf2 bma2 bmb2 cy2 id6 id8 cim2 pl2 fc2c )
#	all blank
ignore_columns += %w( bm1d_7_int cc2 cd11b_14 cd11b_7 cd11c_14 cd11c_7 
	cd16_14 cd16_7 cd1a_7 cd21_14 cd21_7 cd22_14 
	cd22_7 cd23_14 cd23_7 cd24_14 cd24_7 cd25_14 cd25_7 
	cd2_7 cd38_14 cd38_7 cd3cd4_14 cd3cd4_7 cd3cd8_14 
	cd2_7 cd38_14 cd38_7 cd3cd4_14 cd3cd4_7 cd3cd8_14 
	cd3cd8_7 cd40_14 cd40_7 cd41_14 cd41_7 cd45_14 cd45_7 cd4_7 cd56_7 
	cd57_14 cd57_7 cd61_7 cd71_14 cd71_7 cd7_7 cd8_7 cd9_14 cd9_7 
	cdw65_14 cdw65_7 cim8 cy_compkaryb cy_deletion
	cy_diag_conv cy_diag_fish cytoigm_14 cytoigm_7
	fsh_hospcomments fsh_percpos fsh_ucbpercpos fsh_ucbprobes
	glyca_14 glyca_7 nd6c other3_7 other4_7 other5_7 pe10a
	pe11a pe5a pe6a pe7a pl4 specify3_7 specify4_7 specify5_7 sty3k1
	sty3s sty3s1 sty3t sty3t1 sty3u sty3u1 sty3y 
	sty3y1 sty3z sty3z1 sty4a sty4b 
	surfimmunog_14 surfimmunog_7 )
#	no new name so irrelevant for YNDK 
ignore_columns += %w( att13 bm1d_14_int bm1d_28_int cbf6b dischargesummarydate dischargesummaryfound fabclass fc1c1_backup fc1c2_backup fc1l10a fc1l10b fc1l10c fc1l11a fc1l11b fc1l11c fc1l12a fc1l12b fc1l12c fc1l13a fc1l13b fc1l13c fc1l14a fc1l14b fc1l14c fc1l8a fc1l8b fc1l8c fc1l9a fc1l9b fc1l9c icdo icdo1 icdocodeid_1990 icdocodeid_2000 nd4a nd5a nd6a sty3l1 sty3m1 sty3n sty3n1 sty3o sty3o1 sty3p sty3p1 sty3q sty3q1 sty3r sty3r1 )
		(f=CSV.open( ENV['csv_file'], 'rb',{
				:headers => true })).each do |line|
			line.each { |column,value|
				unless ignore_columns.include?(column)
					columns_hash[column] ||= Hash.new(0).with_indifferent_access 
					columns_hash[column][value.to_s] += 1	#	don't want a nil key as won't sort
				end
			}
		end
		aliases = Abstract.aliased_attributes
		columns_hash.keys.sort.each do |column|
			columns_hash[column].keys.sort.each do |value|
#				puts [column,value,columns_hash[column][value]].to_csv
				puts [column,
					((aliases.has_key?(column))?aliases[column]:''),
					value,columns_hash[column][value]
				].to_csv
			end
		end
	end	#	task :show_all_column_values => :environment do

	desc "Show given columns in each row of csv file"
	task :show_columns => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])
		env_required('columns','is required comma separated list')
		columns = ENV['columns'].split(/\s*,\s*/)

		f=CSV.open( ENV['csv_file'], 'rb')
		header_line = f.gets
		f.close

		columns.each do |c|
			unless header_line.include?(c)
				puts
				puts "'#{c}' is not a valid column"
				puts "Columns are #{header_line.join(', ')}"
				puts
				exit(1)
			end
		end

		(f=CSV.open( ENV['csv_file'], 'rb',{
				:headers => true })).each do |line|
			columns.each { |c| printf("%s\t",line[c]) }
			puts
		end
	end

	desc "Max column content length"
	task :max_column_content => :environment do
		env_required('csv_file')
		file_required(ENV['csv_file'])
		max_lengths = Hash.new(0).with_indifferent_access
		(f=CSV.open( ENV['csv_file'], 'rb',{
				:headers => true })).each do |line|
			line.each { |h,f|
				max_lengths[h] = f.to_s.length if f.to_s.length > max_lengths[h]
			}
		end
#		aliases = Abstract.aliased_attributes
		max_lengths.keys.sort.each do |k|
#			puts "#{k.rjust(20)} #{max_lengths[k].to_s.rjust(5)} #{(aliases.has_key?(k))?aliases[k]:''}"
			puts "#{k.rjust(20)} #{max_lengths[k].to_s.rjust(5)}"
		end
	end

	desc "Count columns in each row of csv file"
	task :count_columns => :environment do
		env_required('csv_file')
#		file_required(ENV['csv_files'])
		Dir[ENV['csv_file']].each do |csv_file|
			count_columns_in_csv_file(csv_file)
		end
	end

	def count_columns_in_csv_file(csv_file)
		puts "Counting columns in #{csv_file}"
		counts = Hash.new(0)
		(f=CSV.open( csv_file, 'rb' )).each do |line|
			counts[line.length] += 1
		end

		counts.each do |k,v|
			puts "#{v} rows have #{k} columns"
		end
	end

	def env_required(var,msg='is required')
		if ENV[var].blank?
			puts
			puts "'#{var}' is not set and #{msg}"
			puts "Rerun with #{var}=something"
			puts
			exit(1)
		end
	end

	def file_required(filename,msg='is required')
		unless File.exists?(filename)
			puts
			puts "File '#{filename}' was not found and #{msg}"
			puts
			exit(1)
		end
	end

end
