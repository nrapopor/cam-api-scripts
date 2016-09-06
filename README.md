## Description
This is a short description of the RSpec to DTP processing script. This script leverages the CAM API scripts    
provided here as well

## Requirements
 * __DTP__, __jtest__, __CAM__, and A J2EE container (like _Tomcat_) with the application deployed and the agent properly configured.    
   At this point the coverage upload has been tested but it is disabled for now since there is no     
   instrumentation for the tests.
	
 * Please see the `bin/cam_functions.sh` and `bin/parse_functions.sh` for all prerequisite software that needs    
   to to be available on the machine (in addition to the list above)
	
## Configuration
 * All scripts support the `bin/<script name>.sh -h` option to display comprehensive help for each script

 * All the defaults can be found in the `bin/cam_setenv.sh` and `bin/parse_setenv.sh`. Please modify them to    
   match your DTP and installation
	
 * Currently the scripts expect to find the config file `CAM.server.config` in the current folder, but    
   that can be changed by altering the defaults

## Call sequence
CAM API call sequence. For an implementation example see `bin/parse_api.sh`

* `bin/initServer.sh` -- initialize server connection please see the help for the script to set up the     
   default config file.
* `bin/initSession.sh` -- initialize a new session (closes any open sessions) please see the help for    
   the behavior details
* `<test loop>`
  * `bin/addTest.sh`    -- can be called only once per test
    * `<perform test here>`
  * `bin/updateTest.sh` -- can be called several times per test unless `status` is passed (that closes the test)
* `<end loop>`
* `bin/getReport.sh`            -- gets the test report and coverage results and uploads them to DTP 
* `bin/removeClosedSessions.sh` -- removes any closed sessions from CAM
* `bin/closeSession.sh`		-- closes the active session opened by `bin/initSession.sh` script 
 
## Example
* bin/parse_api_sh - this file will require the RSpec API xml (I used on provided and it's included    
  here in the main folder)    
```bash
        bin/parse_api.sh -f examples/RSpecResults/report.xml -S examples/RSpecResults/static_coverage.xml -P Project1 -U
```

## Author
	Nick Rapoport

## Copyright
	Copyright: 2016-09-05 -- Parasoft Corporation -- All rights reserved 


