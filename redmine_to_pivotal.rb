#!/usr/bin/ruby

# Convert Redmine CSV export files into Pivotal Tracker CSV for importing
# Author: Mark Lubarsky
# Creation Date: 4/11/2012

# USAGE: ruby redmine_to_pivotal.rb redmine_csv_file.csv pivotal_csv_file.csv

#This file converts Redmine tool CSV export into Pivotal for importing purposes.

#NOTE: This code automatically maps types, status and estimate based on Pivotal rules

require 'rubygems'
require 'fastercsv'
require 'ruby-debug'

redmine_csv_file = ARGV[0]
pivotal_csv_file = ARGV[1]


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

redmine_attr_array = from_redmine(redmine_csv_file)

to_pivotal(pivotal_csv_file, redmine_attr_array) 

puts "converted #{redmine_csv_file} to #{pivotal_csv_file} (#{redmine_attr_array.length} rows)"





