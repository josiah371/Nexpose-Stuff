#!/usr/bin/env ruby
######################################
# The MIT License (MIT)
# Copyright (c) Created by Rapid7
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
#
# Export a site from a console. Updated for yaml
#
require 'yaml'
require 'nexpose'
include Nexpose

## method to read and parse a YAML configuration file and return a openstruct
def getConfig( configFilename = "/opt/scripts/config.yml")
    ## read the YAML config file
    config = OpenStruct.new( YAML.load_file( configFilename ) )

    return config
end
$CONFIG = getConfig()
#set Connection
nsc = Nexpose::Connection.from_uri( $CONFIG.nexposeURI, $CONFIG.nexposeUser, $CONFIG.nexposePassword )
# Login to NSC and Establish a Session ID
nsc.login
at_exit { nsc.logout }

# Allow the user to pass in the site ID to the script.
site_id = ARGV[0].to_i

# Write the site configuration to a file.
site = Site.load(nsc, site_id)
File.write('site.xml', site.to_xml)

# Grab scans and sort by scan end time
scans = nsc.site_scan_history(site_id).sort_by { |s| s.end_time }.map { |s| s.scan_id }

# Scan IDs are not guaranteed to be in order, so use a proxy number to order them.
i = 0
scans.each do |scan_id|
  nsc.export_scan(scan_id, "scan-#{i}.zip")
  i += 1
end
