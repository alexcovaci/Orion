# Orion

## Screenshots

![Screenshot 1](/Screenshots/browser.png)

![Screenshot 2](/Screenshots/extension.png)


## Description

Orion is a lightweight macOS tabbed browser based on WebKit with support for WebExtensions.

You will need to download, compile WebKit, and copy the framework and dependencies under /WebKit. Instructions on building WebKit can be found here: https://webkit.org/building-webkit/

You can install any extension from addons.mozilla.org. Visiting any extension page such as https://addons.mozilla.org/en-US/firefox/addon/top-sites-button/ will change the "Add to..." button's title to "Add to Orion."

Orion's extensions API is for the time being limited to "browser.topSites.get", "browser.tabs.create", "browser.tabs.update" and a stubbed out "browser.storage.local", with plenty of room to grow.


## UI Overview

Orion is multi-tabbed. You can open new tabs with the plus button. The tab's close button animates in on hover.

You can navigate back and forward in the history list.

Loading progress is indicated in the location bar, in a similar fashion to Safari.


## Notes

The chosen architecture for the app is MVC-C, making use of injected dependencies. Right now there are 2 coordinators, BrowserCoordinator and ExtensionsCoordinator, injected per browser window.

Visiting "addons.mozilla.org" spoofs a Firefox user agent. Clicking the "Add to Orion" button downloads and installs the extension, if the user allows it. Upon installation a toolbar button is added for the extension. Long clicking on an extension's toolbar icon allows the user to remove the extension.

The extensions' popups are served using a custom schema handler ("extension"). This can be further expanded to support additonal schemas, e.g. "about", etc.

All the navigation is captured, including navigation through the manipulation of the history API via the WKHistoryDelegate's didUpdateHistoryTitle which is only triggered once a page load is completed.

Orion's user data (extensions, history) resides in "~/Library/Containers/Orion/Data/Documents/".


## Challenges

The breadth and scope of the WebExtensions API spec, and making sure implementation is up to said spec is going to be a challange. While laying out the graound work, Safari's inspection tool proved invaluable.