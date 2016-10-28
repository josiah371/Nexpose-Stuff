#!/usr/bin/env ruby
######################################
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
require 'yaml'
require 'date'

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

sql = 'SELECT ds.site_id, ds.last_scan_id, dsc.finished
        FROM dim_site ds
        JOIN dim_scan dsc ON ds.last_scan_id = dsc.scan_id'

report_config = Nexpose::AdhocReportConfig.new(nil, 'sql')
report_config.add_filter('version','1.3.1')
report_config.add_filter('query',sql)

start_ts = DateTime.now
puts "Starting last scan query at #{start_ts}"

report = report_config.generate( nsc, timeout = nil)

end_ts = DateTime.now
delta_ts = end_ts.to_time - start_ts.to_time
puts "Finished last scan query at #{end_ts} with #{report.scan(/\n/).length} results"
puts "Query took #{delta_ts} seconds"
