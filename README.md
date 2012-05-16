alpine-notify
=============

Script to run alpine mail client using a notify-osd notification system.

This depends on the command `notify-send`. This command is usually
made available by the libnotify package, but that may vary between
distros.

INSTALLATION
To install this:
	- Simply place this script anywhere you want (preferably in your $PATH).
	- Check if the variables defined inside match your config (specially the $alpine variable).
	- Run the script instead of running alpine.

The script takes care of starting a notifier function and starting
alpine for you.