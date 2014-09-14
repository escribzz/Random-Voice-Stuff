#!/bin/sh
# Erik Knight to transcribe voicemails with asterisk using Google's translation service
# You have to overwrite the mailcmd in asterisk to call this file mailcmd=/usr/bin/vm-modify.sh

TMPFILE=`/bin/mktemp .XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
/bin/cat > /tmp/voicemail.tmp$TMPFILE

EXT=`/bin/cat /tmp/voicemail.tmp$TMPFILE | /usr/bin/extract.pl`

# Transcribe the voicemail for the given extension
/usr/bin/transcribe.pl  /tmp/$EXT > /tmp/transcribe.tmp$TMPFILE

# Append the outgoing email with the voicemail transcription
/bin/cat /tmp/voicemail.tmp$TMPFILE \
| /bin/sed "/Voicemail Transcription:/ r /tmp/transcribe.tmp$TMPFILE" \
| /usr/sbin/sendmail -t

# Clean up temporary files
rm -f /tmp/voicemail.tmp$TMPFILE
rm -f /tmp/transcribe.tmp$TMPFILE
rm -f /tmp/$EXT
rm -f /tmp/.$EXT.b64
rm -f /tmp/$TMPFILE
