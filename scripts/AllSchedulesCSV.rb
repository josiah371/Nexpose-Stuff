#!/usr/bin/env ruby
# Copyright (c) 2016 Josiah371 - outofc0ntr0l
# The MIT License (MIT)
# Copyright (c) 2016 Josiah371 - outofc0ntr0l
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
######################################
require 'yaml'
require 'nexpose'
require 'csv'
include Nexpose


def getConfig( configFilename = "/opt/scripts/config-new.yml")
 ## read the YAML config file
 config = OpenStruct.new( YAML.load_file( configFilename ) )
 return config
end
#get config
$CONFIG = getConfig()
nsc = Nexpose::Connection.from_uri( $CONFIG.nexposeURI, $CONFIG.nexposeUser, $CONFIG.nexposePassword )
# Login to NSC and Establish a Session ID
nsc.login
at_exit { nsc.logout }

# Check Session ID
if nsc.session_id
    puts 'Login Successful'
else
    puts 'Login Failure'
    exit
end
nexS = []
#get a list of Ids
s = nsc.sites
s.each do |i|
        nexS << i.id
end
puts "Total Sites: #{nexS.count}"
puts "Checking each site for a schedule ... "
def self.generate_csv(nsc, n)
        
	CSV.open("schedules.csv", "wb") do |csv|
	csv << ["Site Name", "Start Date" , "Interval" , "Type" , "Enable" , "Template" , "Next Run Time" , "Repeater Type" , "Time Zone"] 
	n.each do |cSiteId|
		#Load the site
		puts "Loading Site: #{cSiteId}"
		tmpSiteId = Site.load(nsc, cSiteId)
		#check for schedules
		puts "#{tmpSiteId.schedules.count} Schedules Found"
		puts "Current Schedules ..."
		if tmpSiteId.schedules.count > 1
			#loop through and disable schedules
			tmpSiteId.schedules.each do |tmpSiteSchedule|
			#get the schedule 1 by 1 and disable
			csv << [tmpSiteId.name, tmpSiteSchedule.start, tmpSiteSchedule.occurrence, tmpSiteSchedule.type, tmpSiteSchedule.enabled, tmpSiteSchedule.scan_template_id, tmpSiteSchedule.next_run_time, tmpSiteSchedule.max_duration, tmpSiteSchedule.repeater_type, tmpSiteSchedule.timezone]
			end
		elsif tmpSiteId.schedules.count > 0
			#disable the 1 site
			puts "tmpSiteId.name add"
			csv << [tmpSiteId.name, tmpSiteId.schedules[0].start, tmpSiteId.schedules[0].occurrence, tmpSiteId.schedules[0].type, tmpSiteId.schedules[0].enabled, tmpSiteId.schedules[0].scan_template_id, tmpSiteId.schedules[0].next_run_time, tmpSiteId.schedules[0].max_duration, tmpSiteId.schedules[0].repeater_type, tmpSiteId.schedules[0].timezone]
		end
	end
end
end
generate_csv(nsc, nexS)
