HWS Weeding Manager

Copyright 2014 Hobart & William Smith Colleges

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

--------------------------------------------------------------------------

Release notes

4/28/14

The HWS implementation of Weeding Manager depends on other parts of our
web infrastructure that are currently under revision to be released as
separate standalone modules. The currently released code will need a certain
amount of tweaking in order to make it work in a non-HWS environment. As
much as possible, known issues to be addressed are listed below:

1. Login and session variables
2. Conspectus module
3. Application.cfc and config files
4. CFC locations, get.cfm and update.cfm, and CFC security
5. SQL table creation

1. Login and session variables

The HWS implementation relies on a login script that is used across the 
library.hws.edu web site. Users are authenticated against the campus LDAP
server and then identified in the Voyager tables to create a session.user 
object containing the user's name, barcode, campus ID number, patron type 
(faculty, staff, student), department, email address, etc. Users are further
checked against a SQL Server table to determine if they have any library
staff permissions, and if so these are stored in the session.authorization
variable.

The logic to determine logged-in and authorized users is found in the 
isLoggedIn() and isAuthorized() functions in config.cfm, and should be 
changed to reflect the implementing campus's environment. In the future the
HWS login environment may be released as a separate module on github if 
there is sufficient interest.

2. Conspectus module

The department matching when a barcode is scanned is accomplished using an
as-yet unreleeased conspectus module wherein ranges of LC call numbers are 
linked to different subject areas. This is some of the oldest code implemented
at HWS, underlying several different projects, and will be cleaned up in the
summer of 2014 prior to being released on github as hws-conspectus. In the
meantime, table structure for the tables needed to implement the conspectus
in its current incarnation is included in conspectus.sql.

3. Application.cfc and /cfg/application.cfg

The HWS infrastructure includes a single Application.cfc file in the web root 
that is used to set up an environment for all of the various CF web apps that 
make up the library.hws.edu web site. At application startup, the 
/cfg/application.cfg file is ingested and a number of application parameters 
are set, including dot-notation paths to the various CFCs.

The currently incomplete HWS-Core module (https://github.com/bwmcdonald/hws-core) 
is intended to allow other interested institutions to use this structure for 
their convenience, although this will need to be thoroughly tested to make sure it 
doesn't stomp on any existing Application.cfc settings.

4. CFC locations, get.cfm and update.cfm, and CFC security

CFCs are generally installed in a directory outside the webroot and their
location specified via application variables (e.g., #application.weeding.cfc# 
is the dot-notation path to weeding.cfc.) In the HWS setup these variables are
set in application.cfg; until the HWS-Core module is available, however, they 
should be set in config.cfm.