# The MIT License (MIT)
# Copyright (c) 2016 Josiah371 - outofc0ntr0l - Not sure who wrote this originally possibly from the 
# community or from Rapid7. Modified for yaml
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
# associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial 
# portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
require 'yaml'
require 'nexpose'
require 'csv'
include Nexpose

def getConfig( configFilename = "/opt/scripts/config-new.yml")
 ## read the YAML config file
 config = OpenStruct.new( YAML.load_file( configFilename ) )
 return config
end

CSV_FILE = 'Site_schedules.csv'
year = Time.now.strftime('%Y')
date = Time.now.strftime('%m-%d-%Y')

$CONFIG = getConfig()
@nsc = Nexpose::Connection.from_uri( $CONFIG.nexposeURI, $CONFIG.nexposeUser, $CONFIG.nexposePassword )

## Login to Nexpose
@nsc.login

## Logout when the script exits
at_exit { @nsc.logout }

## Getting the String with Schedules from Nexpose
schedules = @nsc.console_command('schedule')

## Converting String to Array -- Splitting by New Line
array = schedules.split("\n")

## Removing Header rows from Array
array.shift(2)

## Opening New CSV File with Current Date Stamp
CSV.open("#{CSV_FILE}-#{date}",'w') do |row|
	# Adding Header Row to CSV file
	row << ['Site Name', 'Next Scan Date-Time']
	array.each do |str|
		# Skip all schedules that are NOT Site related
		next if !str.include? 'Scan:'
		# Format String to extract Site Name and Date/Time of Next Scan
		site_date_sched = str.split(year)
		date_sched = site_date_sched[1].split("Schedule")
		date =  year+date_sched[0]
		date_formatted = date[0..15]
		site = site_date_sched[0].sub('                            ','')
		date_formatted
		site_name = site.sub('Scan: ','')
		# Add Data row to CSV file
		row << [site_name, date_formatted]
	end
end

