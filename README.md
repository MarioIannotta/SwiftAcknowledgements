# SwiftAcknowledgements

SwiftAcknowledgements is a tiny command line tool to extract the licenses of your Swift package manager dependencies and format them to be easily bundled in the Settings.bundle of your app.

## Usage
```
swift-acknowledgements generate <checkouts-path> <output-path>
```

## Example
```
swift-acknowledgements generate \
    /Users/user/Library/Developer/Xcode/DerivedData/project/SourcePackages/checkouts \
    /Users/user/Desktop/out
```
The following command will create a folder named "out" in your desktop containing 
- an `Acknowledgements.plist` file that will be the entry point to browse all the licenses extracted;
- an `Acknowledgements` folder that will contain all the extracted licenses in a plist format;

The last step would be adding an entry in your `Settings.bundle/Root.plist` to explore the acknowledgements.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>StringsTable</key>
	<string>Root</string>
	<key>PreferenceSpecifiers</key>
	<array>
        // this entry will add a row "Acknowledgements" in the Settings of your app.
		<dict>
			<key>Type</key>
			<string>PSChildPaneSpecifier</string>
			<key>Title</key>
			<string>Acknowledgements</string>
			<key>File</key>
			<string>Acknowledgements</string>
		</dict>
	</array>
</dict>
</plist>
```

## Demo
<img src="Demo.gif" width=200>

## License

SwiftAcknowledgements is available under the MIT license. See the LICENSE file for more info.

## TODOs:

* [ ] Add options to exclude some libraries
* [ ] Add Swift Package Manager plugin

