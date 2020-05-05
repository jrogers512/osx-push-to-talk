#!/bin/bash
#After we do a build in xcode, lets package it up!

source .env
APP_FILENAME=PushToTalk
[ -z ${GITHUB_TOKEN} ] && GITHUB_TOKEN="d35b0ab1f33b3f8c1008517796593a02d3c411748"
GITHUB_USER="jrogers512"
GITHUB_PROJECT="osx-push-to-talk"
DST="DerivedData/${APP_FILENAME}/Build/Products/Debug"
VERSION="$( /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ${APP_FILENAME}/Info.plist )"

#if the target is there, quit with error message
[[ -f ${DST}/${APP_FILENAME}-$VERSION.dmg ]] && echo "${DST}/${APP_FILENAME}-$VERSION.dmg already exists, quitting..." && exit -1

#get the directory ready (if pandoc is missing, will proceed without the README)
ln -sf ~/Applications ${DST}/
rm -rf ${DST}/*.swiftmodule
pandoc README.md -f markdown -t rtf -s -o ${DST}/README.rtf
pandoc CHANGELOG.md -f markdown -t rtf -s -o ${DST}/CHANGELOG.rtf

hdiutil create /tmp/$$.dmg -ov -volname "${APP_FILENAME} v$VERSION" -srcfolder $DST/
hdiutil convert /tmp/$$.dmg -format UDZO -o ${DST}/${APP_FILENAME}-$VERSION.dmg

# uses https://gist.github.com/typebrook/4947769e266173303d8848f496e272c9
github-release.sh github_api_token=$GITHUB_TOKEN \
    repo=${GITHUB_USER}/${GITHUB_PROJECT} tag=$VERSION \
    type=asset filename=$DST/${APP_FILENAME}-$VERSION.dmg \
    action=overwrite create=true > /tmp/${APP_FILENAME}-$VERSION-release.json
RESULT = $?
#This isn't storing properly while in a shell script... needs stroubleshooting
URL="$( sed "s|[^{]*||" /tmp/PushToTalk-2.0.1-release.json | jq .browser_download_url )

#Cleanup
rm /tmp/${APP_FILENAME}-$VERSION-release.json /tmp/$$.dmg

# If all went well, open the package
if $RESULT; then 
    open $DST/${APP_FILENAME}-$VERSION.dmg
    echo "$VERSION has been published to $URL"
else
    echo "Something went wrong.  Take a look at /tmp/$$.json or the output above."
fi
echo $RESULT