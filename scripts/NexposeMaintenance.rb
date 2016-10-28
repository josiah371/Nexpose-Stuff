#!/usr/bin/env ruby
######################################
# Created By: Josiah Inman
# Date: 10/15/2015
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
require 'ostruct'
require 'nexpose'
require 'logger'

## method to read and parse a YAML configuration file and return a openstruct
def getConfig( configFilename = "/opt/scripts/config.yml")
    ## read the YAML config file
    config = OpenStruct.new( YAML.load_file( configFilename ) )

    return config
end

def getLog()
    ## Initiate Logging
    if $CONFIG.logFile.nil?
        log = Logger.new($stderr)
    else
        log = Logger.new($CONFIG.logFile)
    end

    ## set the log level
    log.level = Logger.const_get($CONFIG.logLevel.upcase)

    return log
end

$CONFIG = getConfig()
$LOG = getLog()

$LOG.debug("Connecting to the nexpose console")
nsc = Nexpose::Connection.from_uri( $CONFIG.nexposeURI, $CONFIG.nexposeUser, $CONFIG.nexposePassword )

$LOG.debug("Logging into the console")
nsc.login

$LOG.debug("Initiating maintenance tasks: clean_up, compress, reindex")
nsc.db_maintenance( clean_up = true, compress = true, reindex = true )

$LOG.debug("Logging out of the console")
nsc.logout
