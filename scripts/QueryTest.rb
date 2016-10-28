#!/usr/bin/env ruby
######################################
# Created By: Josiah Inman
# Date: 10/5/2016
# Description: Used to test Queries
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
require 'csv'
require 'nexpose'
require 'socket'
require 'highline/import'
require 'securerandom'
include Nexpose

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
end
def getConfig( configFilename = "/opt/scripts/config-new.yml")
 ## read the YAML config file
 config = OpenStruct.new( YAML.load_file( configFilename ) )
 return config
end
device = 1977684
query1 = "select distinct da.ip_address, da.host_name, dacs.aggregated_credential_status_description
	from fact_asset fa
	join dim_aggregated_credential_status dacs USING (aggregated_credential_status_id)
	join dim_asset da using (asset_id)
	order by da.ip_address"

query = "SELECT DISTINCT *
FROM dim_asset_operating_system
where certainty = 1 and asset_id = 1977684"
$CONFIG = getConfig()
nsc = Nexpose::Connection.from_uri( $CONFIG.nexposeURI, $CONFIG.nexposeUser, $CONFIG.nexposePassword )
nsc.login

#build report
report_config = Nexpose::AdhocReportConfig.new(nil, 'sql')
report_config.add_filter('version', '2.0.2')
report_config.add_filter('query', query)
report_config.add_filter('device', device)
begin
	puts "Checking Authentication, Please wait ..."
	report_output = report_config.generate(nsc)
	sleep(20)
end while report_output.nil
csv_output = CSV.parse(report_output, {:headers => :first_row} )
puts "#{csv_output.count}"

nsc.logout
