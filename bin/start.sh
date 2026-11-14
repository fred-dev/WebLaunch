#!/bin/sh

###############################################################################
## Configuration variables 

APP_FOLDER="/mnt/us/extensions/WebLaunch"

APPREG="/var/local/appreg.db"

APP_ID="com.PaulFreund.WebLaunch"
APP_ID_STRING="'$APP_ID'"

## WARNING - Changing the extension path after first run will result in errors,
## the following commands delete old keys from the app registry
# sqlite3 $APPREG "delete from handlerIds where handlerId=$APP_ID_STRING"
# sqlite3 $APPREG "delete from properties where handlerId=$APP_ID_STRING"

###############################################################################
## Register powerbutton handler

FILE_RULES="/etc/udev/rules.d/98-yoshibutton.rules"
FILE_NOTIFY="/lib/udev/bin/notifyyoshibutton"

#------------------------------------------------------------------------------
# Rules
if [ ! -f $FILE_RULES ]
then
	mntroot rw
	echo "KERNEL==\"yoshibutton\",  RUN+=\"$FILE_NOTIFY\"" > $FILE_RULES
	udevadm control --reload-rules
	mntroot ro
fi

#------------------------------------------------------------------------------
# Notifier
if [ ! -f $FILE_NOTIFY ]
then
	mntroot rw
	echo '#!/bin/sh' > $FILE_NOTIFY
	echo '/usr/bin/lipc-send-event com.lab126.system.event yoshibutton' >> $FILE_NOTIFY
	chmod +x $FILE_NOTIFY
	mntroot ro
fi

###############################################################################
## Register application if neccessary

#------------------------------------------------------------------------------
# Application Id
REG_ID=$(sqlite3 $APPREG "select handlerId from handlerIds where handlerId=$APP_ID_STRING")

if [[ -z "$REG_ID" ]]
then
	echo "Application Id not registered, registering..."
	sqlite3 $APPREG "INSERT INTO handlerIds VALUES ($APP_ID_STRING)"
fi

#------------------------------------------------------------------------------
# Application command
# Firmware 5.12 refuses a bare path ("Content uri did not resolve to a valid
# local path"), so the folder is registered as a file:/// URI, replacing any older row.
sqlite3 $APPREG "delete from properties where handlerId=$APP_ID_STRING and name='command'"
sqlite3 $APPREG "INSERT INTO properties (handlerId, name, value) VALUES ($APP_ID_STRING,'command','/usr/bin/mesquite -l $APP_ID -c file://$APP_FOLDER/bin/')"

#------------------------------------------------------------------------------
# Application unloadPolicy
REG_UNLOADPOLICY=$(sqlite3 $APPREG "select handlerId from properties where handlerId=$APP_ID_STRING and name='unloadPolicy'")

if [[ -z "$REG_UNLOADPOLICY" ]]
then
	echo "Application unloadPolicy not registered, registering..."
	sqlite3 $APPREG "INSERT INTO properties (handlerId, name, value) VALUES ($APP_ID_STRING,'unloadPolicy','unloadOnPause')"
fi

###############################################################################
## Start the application

# Keep the screen on while the app runs. Set here as well as in index.html,
# since that route goes through pillow; it lasts until the Kindle restarts.
if grep -q "enablePreventScreenSaver: *true" $APP_FOLDER/settings.js 2>/dev/null
then
	lipc-set-prop com.lab126.powerd preventScreenSaver 1
fi

lipc-set-prop com.lab126.appmgrd start app://$APP_ID



