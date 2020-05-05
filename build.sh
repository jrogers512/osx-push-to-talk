#!/bin/bash
#After we do a build in xcode, lets package it up!

VERSION=$( /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" PushToTalkTests/Info.plist )

#if the target is there, quit with error message
[[ -f bin/PushToTalk-$VERSION.dmg ]] && echo "bin/PushToTalk-$VERSION.dmg already exists, quitting..." && exit -1

#get the directory ready (if pandoc is missing, will proceed without the README)
ln -sf ~/Applications DerivedData/PushToTalk/Build/Products/Debug/
rm -rf DerivedData/PushToTalk/Build/Products/Debug/PushToTalk.swiftmodule
pandoc README.md -f markdown -t rtf -s -o DerivedData/PushToTalk/Build/Products/Debug/README.rtf
pandoc CHANGELOG.md -f markdown -t rtf -s -o DerivedData/PushToTalk/Build/Products/Debug/CHANGELOG.rtf

hdiutil create /tmp/PushToTalk-$VERSION.dmg -ov -volname "PushToTalk v$VERSION" -srcfolder DerivedData/PushToTalk/Build/Products/Debug/
hdiutil convert /tmp/PushToTalk-2.0.1.dmg -format UDZO -o bin/PushToTalk-2.0.1.dmg
open bin/PushToTalk-$VERSION.dmg