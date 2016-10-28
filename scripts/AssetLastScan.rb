#!/usr/bin/env ruby
# Copyright (c) 2016 Josiah371 - outofc0ntr0l
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
require 'nexpose'
require 'optparse'
require 'ostruct'
require 'yaml'

def getConfig( configFilename = "/opt/scripts/config.yml")
    ## read the YAML config file
    config = OpenStruct.new( YAML.load_file( configFilename ) )
end

def getArgs
    options = {}
    config = OpenStruct.new
    config.columns = []

    OptionParser.new do |opts|
        opts.on("-sMANDATORY", "--ip=MANDATORY", "Set IP to look up") { |ipArg| config.ip = ipArg }
        opts.on
    end.parse!
    config.columns.uniq!
  return config
end
def getAsset(nsc, config)
    assetf = nsc.filter( Nexpose::Search::Field::IP_RANGE, Nexpose::Search::Operator::IN, [config.ip, config.ip] )
    return assetf
end
def mainRun()
#get the config options
$CONFIG = getConfig()

nsc = nil
nsc = Nexpose::Connection.from_uri( $CONFIG.nexposeURI, $CONFIG.nexposeUser, $CONFIG.nexposePassword )

exitVal = 0
nsc.login
args = getArgs()
assetf = getAsset(nsc, args)
assetf.each do |a|
    puts "Asset IP: #{a.ip}, Last Scan Date: #{a.last_scan}, Site ID: #{a.site_id}"
    #get last scan ID
    completedScan = nsc.completed_scans(a.site_id)
    completedScan.each do |cs|
            puts "Completed Scan #{cs.id}" 
            puts "DEBUG: entering competed asset search "
            completedAsset = nsc.completed_assets(cs.id)
            puts "Completed Scan Asset Count: #{completedAsset.count}"
            completedAsset.each do |ca|
                puts "Completed Asset: #{a.ip}"
                puts "seaching for asset #{ca.ip}"
                
		if ca.ip == a.ip
		    puts "Asset Last Scanned by #{cs.engine_name}"
                    return cs.engine_name
                end
             # end
            end
       
    end
end

nsc.logout
end

mainRun()
