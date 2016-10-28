#!/usr/bin/env ruby
######################################
# Created By: Josiah371
# Date: 10/5/2016
# Description: This script is used
# to login and enable all schedules
# that are disabled.
#
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
include Nexpose

def getConfig( configFilename = "/opt/scripts/config-new.yml")
 ## read the YAML config file
 config = OpenStruct.new( YAML.load_file( configFilename ) )
 return config
end

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
nexS.each do |cSiteId|
    #Load the site
    puts "Loading Site: #{cSiteId}"
    tmpSiteId = Site.load(nsc, cSiteId)
    #check for schedules
    puts "#{tmpSiteId.schedules.count} Schedules Found"
    puts "Updating Schedules..."
    if tmpSiteId.schedules.count > 1
	#loop through and disable schedules
        tmpSiteId.schedules.each do |tmpSiteSchedule|
	#get the schedule 1 by 1 and disable
        	tmpSiteSchedule.enabled = false
		begin
		tmpSiteId.save(nsc)
		
		rescue => e
                #todo write errors to log
		end
        end
    elsif tmpSiteId.schedules.count > 0
        #disable the 1 site
        tmpSiteId.schedules[0].enabled = false
        begin
		tmpSiteId.save(nsc)
        
        rescue => e
        #todo write errors to log
        end
    end
end
