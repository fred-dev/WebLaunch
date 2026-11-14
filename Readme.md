# WebLaunch #

> **Fork note:** this fork runs on newer firmware. It is tested on a basic Kindle (7th generation, 2014) on firmware 5.12.2.2, jailbroken with WinterBreak. Changes from upstream:
>
> * `bin/start.sh` registers the app folder as a `file:///` URI, as the firmware's own apps are registered. A bare path fails with "Content uri did not resolve to a valid local path".
> * `bin/index.html` loads the URL in a full-screen iframe, since `kindle.chrome.createContentWindow` shows a blank screen on 5.12.
> * The power button only sleeps the Kindle on 5.12, so three taps on the top-right corner go back to the home screen. The corner shows a count as each tap lands.
> * `enablePreventScreenSaver` now keeps the screen on. Upstream compared the string pillowHelper returns with a number, so it never applied. `bin/start.sh` also sets `preventScreenSaver` directly.
> * `bin/config.xml` turns off `enableWrsProxy`, so requests go directly to the URL instead of through Amazon's proxy, which can't reach a local network address.

WebLaunch is an extension for the Kindle Touch and Kindle PaperWhite with JailBreak and the application launcher KUAL. It is designed to open a URL without the browser frame (the black status bar can be removed too) to make it look like a native application.

## Install ##

* Make sure your Kindle Touch / Kindle PaperWhite is already Jailbreaked
* Make sure you have KUAL installed and the "extensions" folder exists 
* Copy the WebLaunch folder to the "extensions" folder ( don't rename it without changing bin/start.sh first )
* Copy the settings.example.js in the WebLaunch folder to settings.js and change its contents to fit your needs

## Uninstall ##

To remove all traces of WebLaunch call the uninstall.sh script in the bin folder of the extension and delete the WebLaunch folder afterwards. If you changed any installation variables in start.sh make sure you also change them in uninstall.sh before execution.

## Background ##

WebLaunch is based on "mesquite" former WAF and utilizes the "Kindle" template library and a few system librarys based on it to bring as much native browser behaviour as possible.

## Notes ##

Special thanks go to the folks at mobileread.com for their great work opening up the Kindle.
