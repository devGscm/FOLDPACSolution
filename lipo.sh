#!/bin/sh

lipo -remove i386 ./Carthage/Build/iOS/BarcodeScanner.framework/BarcodeScanner -o ./Carthage/Build/iOS/BarcodeScanner.framework/BarcodeScanner
lipo -remove x86_64 ./Carthage/Build/iOS/BarcodeScanner.framework/BarcodeScanner -o ./Carthage/Build/iOS/BarcodeScanner.framework/BarcodeScanner

lipo -remove i386 ./Carthage/Build/iOS/FontAwesome.framework/FontAwesome -o ./Carthage/Build/iOS/FontAwesome.framework/FontAwesome
lipo -remove x86_64 ./Carthage/Build/iOS/FontAwesome.framework/FontAwesome -o ./Carthage/Build/iOS/FontAwesome.framework/FontAwesome

lipo -remove i386 ./Carthage/Build/iOS/Material.framework/Material -o ./Carthage/Build/iOS/Material.framework/Material
lipo -remove x86_64 ./Carthage/Build/iOS/Material.framework/Material -o ./Carthage/Build/iOS/Material.framework/Material

lipo -remove i386 ./Carthage/Build/iOS/Motion.framework/Motion -o ./Carthage/Build/iOS/Motion.framework/Motion
lipo -remove x86_64 ./Carthage/Build/iOS/Motion.framework/Motion -o ./Carthage/Build/iOS/Motion.framework/Motion

lipo -remove i386 ./Carthage/Build/iOS/SQLite.framework/SQLite -o ./Carthage/Build/iOS/SQLite.framework/SQLite
lipo -remove x86_64 ./Carthage/Build/iOS/SQLite.framework/SQLite -o ./Carthage/Build/iOS/SQLite.framework/SQLite

lipo -remove i386 ./Carthage/Build/iOS/SWXMLHash.framework/SWXMLHash -o ./Carthage/Build/iOS/SWXMLHash.framework/SWXMLHash
lipo -remove x86_64 ./Carthage/Build/iOS/SWXMLHash.framework/SWXMLHash -o ./Carthage/Build/iOS/SWXMLHash.framework/SWXMLHash

lipo -remove i386 ./Carthage/Build/iOS/SwiftyJSON.framework/SwiftyJSON -o ./Carthage/Build/iOS/SwiftyJSON.framework/SwiftyJSON
lipo -remove x86_64 ./Carthage/Build/iOS/SwiftyJSON.framework/SwiftyJSON -o ./Carthage/Build/iOS/SwiftyJSON.framework/SwiftyJSON
