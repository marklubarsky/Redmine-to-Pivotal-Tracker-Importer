require 'rubygems'
require 'fastercsv'
require 'ruby-debug'


def from_redmine(file_path)
	"#,Status,Project,Tracker,Priority,Subject,Assigned To,Category,Target version,Author,Start date,Due date,% Done,Estimated time,Parent task,Created,Updated,Description"
	FasterCSV.read(file_path, { :headers           => true })
end 

def status_to_pivotal(redmine_status)
	case redmine_status
	when "New"
		"unscheduled"
	when "In Progress"	
		"started"
	when "Resolved"
		"accepted"
	else
		"unscheduled"		
	end	
end	

def type_to_pivotal(redmine_type)
	case redmine_type
	when "Bug"
		"bug"
	when "Feature"	
		"feature"
	when "Activity"
		"chore"
	else
		"chore"		
	end	
end

def to_pivotal(file_path, redmine_attr_array)
  	FasterCSV.open(file_path, "w") do |csv|
		csv <<	"Story,Labels,Story Type,Current State,Created at,Accepted At,Description,Estimate".split(',')
		redmine_attr_array.each do |row|
			csv << [
				row["Subject"],
				["redmine", "redmineID-#{row['#']}", "redmine-#{row["Project"]}"].join(','),
				type_to_pivotal(row["Tracker"]),
				status_to_pivotal(row["Status"]),
				row["Created"],
				status_to_pivotal(row["Status"]) == 'accepted' ? row["Updated"] :  nil,
				row["Description"],
				status_to_pivotal(row["Status"]) == 'unscheduled' ? -1 : 0
			]
		end	
  	end
end	

redmine_csv_files = ['backend', 'product_scrum', 'customer_feedback_redmine'].inject([]) { |redmine_csv_files, f|  redmine_csv_files << File.join(File.dirname(__FILE__), 'data', "#{f}.csv") }

pivotal_csv_files = redmine_csv_files.inject([]) { |pivotal_csv_files, f|  pivotal_csv_files << "#{f}_to_pivotal.csv" }

redmine_csv_files.each_with_index do |redmine_csv_file, i| 
	to_pivotal(pivotal_csv_files[i], from_redmine(redmine_csv_file)) 
end

puts "converted #{redmine_csv_files.inspect} to #{pivotal_csv_files.inspect}"





