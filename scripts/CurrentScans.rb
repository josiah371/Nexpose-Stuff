#!/usr/bin/env ruby
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


##
## Gets the current scans for a site in a silo 
##
require 'nexpose'
require 'yaml'
require 'csv'

#set the silo ID
siloID = nil

## Input CSV File that contains SiloIDs 
silo_file = 'silo_list.csv'

## method to read and parse a YAML configuration file and return a openstruct
def getConfig( configFilename = "/opt/scripts/config.yml")
    ## read the YAML config file
    config = OpenStruct.new( YAML.load_file( configFilename ) )

    return config
end

#get the config options
$CONFIG = getConfig()

# Create a new Nexpose::Connection on the default port
nsc = Nexpose::Connection.from_uri( $CONFIG.nexposeURI, $CONFIG.nexposeUser, $CONFIG.nexposePassword, siloID )

# Login to NSC and Establish a Session ID
nsc.login
at_exit { nsc.logout }
# Check Session ID
if nsc.session_id
    puts 'Login Successful'
else
    puts 'Login Failure'
end

#Get the site name
def getSite(nsc, siteID)
    thisSite = Nexpose::Site.load(nsc, siteID)
    return thisSite
end

thisSite = nil

siteID = 359
thisSite = getSite(nsc, siteID)
#Completed Scans for a site
compScans = nsc.site_scan_history(siteID)
puts "\nScans Completed for site #{thisSite.name}: #{compScans.count}"

#Past Scans (for entire Console)
pastScans = ""
#take the latest 10 scans
ps = nsc.past_scans(10)
puts "\nPast Scans: #{ps.count}\n"
ps.each do |pastScan|
        puts "Site Name: #{getSite(nsc, pastScan.site_id).name},Scan Start:, #{pastScan.start_time}, Scan End: #{pastScan.end_time}, \nEngine ID: #{pastScan.id}, Status: #{pastScan.status}, Duration: #{(pastScan.duration/1000)/60}min, Assets Scanned: #{pastScan.assets}"
end

# Current Scans
cs = ""
cs = nsc.scan_activity
puts "\nScans Running: #{cs.count}\n"

cs.each do |thisScan|
	puts "Site ID: #{thisScan.site_id}, Site Name: #{getSite(nsc, thisScan.site_id).name},  Scan ID: #{thisScan.scan_id}, Engine ID: #{thisScan.engine_id} Status: #{thisScan.status}"
end
puts ""
# Logout
logout_success = nsc.logout
