#!/bin/sh

readonly THUNDER_VERSION="3.3.9"
readonly THUNDER_INFO="/Applications/Thunder.app/Contents/Info.plist"
readonly THUNDER_URL="http://down.sandai.net/mac/thunder_mac.dmg"
readonly THUNDER_FILE="/tmp/thunder$$.dmg"
readonly THUNDER_MOUNT="/tmp/thunder_dmg$$"

set -x

function install_thunder() {
	killall Thunder
	sleep 1
  
	if [[ ! -e $THUNDER_FILE ]];then
		curl -o $THUNDER_FILE $THUNDER_URL
	fi
  
	hdiutil convert $THUNDER_FILE -o ${THUNDER_FILE}.cdr -format UDTO
  
	if [[ -e ${THUNDER_FILE}.cdr ]];then
		mkdir -p $THUNDER_MOUNT
		 hdiutil attach ${THUNDER_FILE}.cdr -mountpoint ${THUNDER_MOUNT} -noverify -noautofsck -nobrowse
		if [[ -d  ${THUNDER_MOUNT}/Thunder.app ]];then
			 ditto $THUNDER_MOUNT/Thunder.app /Applications/Thunder.app
			 xattr -rc /Applications/Thunder.app
			 hdiutil detach  ${THUNDER_MOUNT}
			rm -Rf ${THUNDER_MOUNT}
			rm -Rf ${THUNDER_FILE}.cdr
		else 
			echo "**attaching failed!***"
		fi

	else
		echo "**converting failed!**"
	fi
}

function main() {
	if [[ -e $THUNDER_INFO ]];then
		version=`defaults read ${THUNDER_INFO} CFBundleShortVersionString`
		echo "Version:$version"
		if ! [[ "$THUNDER_VERSION" == "$version" ]];then
			rm -Rf  /Applications/Thunder.app
			install_thunder
		else
			echo "version is up-to-date!"
		fi
	else
		 install_thunder
	fi
	sleep 1
	open -a /Applications/Thunder.app/Contents/MacOS/Thunder 
}

main
