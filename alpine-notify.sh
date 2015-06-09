#! /bin/bash

# Copyright (c) 2012
# Artur de S. L. Malabarba <bruce.connor.am@gmail.com>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

## Set this to your icon FULL path. Leave it as empty for no icon.
iconfile=
## Set this to "/dev/null" to avoid logging
logfile=/tmp/alpine-notify.log
## Check if this matches your alpine settings
fifofile=/tmp/alpine.fifo
## Check if this matches your alpine command
alpine=alpine
## If you have a file with your password in it and you have xclip
## installed, this script can copy it to your clipboard for you.  Set
## this variable to the file path and the password will be copied
## to the clipboard right before starting alpine. This way you can
## just hit Shift+Insert at the password prompt and it gets inserted
## for you. Otherwise, leave it empty.
pfile=

# You shouldn't have to edit anything that follows. If you were forced
# to edit something here to get the behavior you wanted, contact me.

[[ -n $pfile ]] && cat $pfile | xclip -i -selection primary

echo "Starting $0." > $logfile
notify-send -t 1000 "Starting $0." ""

iconcommand=""
[[ -n $iconfile ]] && iconcommand="-i $iconfile"

function _alpine_notify(){
    ignorelines=4

    [[ -n "$1" ]] &&  sleep "$1"
    notify-send -t 1000 "alpine" "Starting subprocess."

    while read L; do
        echo "$L" >> $logfile

        # Ignore some junk lines at the start of the fifo file
        if [[ `wc -l $logfile | awk '{print $1}'` -gt $ignorelines ]]; then
            line=`echo "$L"`

            # Lines in the fifo will have from-name/subject/mailbox
            # Normally these fields are separated by multiple spaces,
            # which this code converts to tabs
            # But in some cases there is only one space
            # These first few lines handle a couple of these cases,
            # adding an extra space so that there are at least two

            # Handle when the from-name is an email address that takes up
            # the entire width of that field, allowing only one space
            line=`echo "$line" | sed 's/^\(+ \)\?\([A-Za-z0-9\.\_\-]\+@[A-Za-z0-9\.\_\-]\+ \)/\2 /'`
            # Handle when the from-name and/or subject was too long and
            # was truncated by alpine, to end in "... "
            line=`echo "$line" | sed 's/\.\.\. /...  /g'`

            # Convert the multiple spaces to tabs
            line=`echo "$line" | sed 's/  \+/\t/g'`

            # Get the from-name, subject, and inbox
            name=`echo "$line" | sed 's/^\(+ \)\?\([^\t]*\)\t\([^\t]*\)[\t ].*/\2/'`
            subject=`echo "$line" | sed 's/^\([^\t]*\)\t\(Re: \?\)\?\([^\t]*\)[\t ].*/\3/'`
            box=`echo "$line" | sed 's/^\([^\t]*\)\t\([^\t]*\)[\t ]\([^\t]*\).*/\3/'`

            notify-send -t 10000 $iconcommand "Mail from $name" "$subject\n-\nIn your $box."

            echo "$name" >> $logfile
            echo "$subject" >> $logfile
            echo "$box" >> $logfile
        fi

    done < <(cat $fifofile)
}

_alpine_notify 5 &

pidn=$!

echo "My pid is $$"
echo "Subprocess pid is $pidn"

$alpine "$@"

# kill -9 $pidn

exit
