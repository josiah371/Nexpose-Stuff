#!/usr/bin/env ruby  
#
# The MIT License (MIT)
# Copyright (c) 2016 Josiah371 - outofc0ntr0l - Originally came from community. Modifidied for YAML 
# and customized outputs.
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
######################################
require 'yaml'
require 'nexpose'


module Nexpose
  class APIRequest
    include XMLUtils
    # Execute an API request
    def self.execute(url, req, api_version='1.1', options = {})
      options = {timeout: 1200000000}
      obj = self.new(req.to_s, url, api_version)
      obj.execute(options)
      return obj
    end
  end

module AJAX
    def self._https(nsc)
      http = Net::HTTP.new(nsc.host, nsc.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      puts 'Overriding timeout'
      http.read_timeout = 1200000000
      http.open_timeout = 1200000000
      http.continue_timeout = 1200000000
      http
    end
  end
end
include Nexpose  

def getConfig( configFilename = "/opt/scripts/config-new.yml")
    ## read the YAML config file
    config = OpenStruct.new( YAML.load_file( configFilename ) )
    return config
end
$CONFIG = getConfig()
 
puts "Enter Asset Group Name to Scan"
@groupname = gets.chomp  
nsc = Connection.from_uri($CONFIG.nexposeURI, $CONFIG.nexposeUser, $CONFIG.nexposePassword )
#login
nsc.login
puts 'logged in to console'
#set the logout command if the script exits
at_exit { nsc.logout }
#assetgroup.load Find the group by name and scan the assets
group_id = nsc.asset_groups.find { |group| group.name == @groupname }.id
puts "Found Site For Scanning: #{group_id}, #{@groupname}"
group = AssetGroup.load(nsc, group_id)
puts "Are you sure you want to Rescan (y/n) #{group.name} "
if gets.chomp == 'y'
	group.rescan_assets(nsc)
end
