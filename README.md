Calndr
======

Simple Pure-Pascal app to read an ics file and do some basic date and
calendar functions.

The initial goal is to show a list of simple events from .ics files.

Usage:

./calndr.ttp  \<directory\>

./calndr.ttp  \<past number of days\> \<future number of days\>

./calndr.ttp  \<directory\> \<past number of days\> \<future number of days\>

e.g.

 ./calndr.ttp  /f/

 ./calndr.ttp  30 30

 ./calndr.ttp  /f/ 30 30
 
will load all the *.ics files from the folder and show details of the events
that fall between a past and future day range.

Events that are due to occur withing less than 24 hours are highlighted.
For these events the duration is shown.


The calendar of the current month is shown.

The timezone is shown but is not taken into account.