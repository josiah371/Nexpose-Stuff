#!/usr/bin/evn ruby 
# The MIT License (MIT)
# Copyright (c) Provided by Rapid7
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
#
# THis will import a site from another console. Updated with yaml
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
 
#Provide the Site.xml File
site_xml = File.read('site.xml')  
xml = REXML::Document.new(site_xml)  
site = Site.parse(xml)  
site.id = -1  
# Set to use the local scan engine.  
site.engine = nsc.engines.find { |e| e.name == 'Local scan engine' }.id  
site_id = site.save(nsc)  
  
# Import scans by numerical ordering  
scans = Dir.glob('scan-*.zip').map { |s| s.gsub(/scan-/, '').gsub(/\.zip/, '').to_i }.sort  
scans.each do |scan|  
  zip = "scan-#{scan}.zip"  
  puts "Importing #{zip}"  
  nsc.import_scan(site.id, zip)  
  # Poll until scan is complete before attempting to import the next scan.  
  last_scan = nsc.site_scan_history(site.id).max_by { |s| s.start_time }.scan_id  
  while (nsc.scan_status(last_scan) == 'running')  
    sleep 10  
  end  
  puts "Integration of #{zip} complete"  
end  
