# hReader

hReader is an open-source, patient-centric mobile health data manager that securely provides patients and their families with their complete health information.

## Project Setup

- The build process requires the `plist` gem. Run `sudo gem install plist --no-rdoc --no-ri` to install the gem in your system Ruby.
- hReader relies on several git submodules. Run `git submodule update --init --recursive` to update all submodules.
- The build process requires the presence of the Xcode "Command Line Tools" package. Navigate to Xcode > Preferences > Downloads > Components and install the package.
- The build process requires openssl source code to be setup in the environment.
  - Download OpenSSL from <http://www.openssl.org/source/>. hReader has been tested against version 1.0.1c.
  - Untar the OpenSSL archive.
  - Create a new source tree in your Xcode preferences (Xcode > Preferences > Locations > Source Trees) called `OPENSSL_SRC` pointed at the location of the OpenSSL source directory.

## API Interaction

hReader talks to RHEx servers using instances of `HRAPIClient`. This class is responsible for all network communication between hReader and any number of RHEx servers. Request a client for a given host using `-[HRAPIClient clientWithHost:]`. Every client operates its own internal request queue &mdash; managed using [Grand Central Dispatch](https://developer.apple.com/library/mac/#documentation/Performance/Reference/GCD_libdispatch_Ref/Reference/reference.html) &mdash; and has both synchronous and asynchronous methods for handling RHEx data.

## Persistence

The app uses CoreData to persist all local data. Instances of `HRMPatient` and `HRMEntry` are responsible for storing all data that comes from RHEx. Data is kept in an SQLCipher-encrypted database using `CMDEncryptedSQLiteStore` (<https://github.com/calebmdavenport/encrypted-core-data>).

hReader uses several managed object contexts to keep the app responsive as it handles fairly large amounts of data. The managed object contexts or organized as follows:

- The root managed object context is created with `NSPrivateQueueConcurrencyType`. This pushes all database reads and writes onto a background thread that is managed by the context. This is not directly accessible to the application.
- The context that is shared by the application is accessible through the app delegate: `-[HRAppDelegate managedObjectContext]`. This context is designed to be accessed on the main thread and is the only descendent of the root application context. It is used throughout the application to show data to the user.
- Child contexts for specific tasks (network operations, user edits, etc) are created as children of the shared application context.

The application automatically cascades saves from the main context to the root context, and from direct descendants of the main context into the main context itself. It is your responsibility to push saves for other related contexts.

## Applets

Each patient stores a list of applets that the user has configured. Available applets are loaded from `HReaderApplets.plist` can be accessed through `HRAppletConfigurationViewController`. Refer to the applet development documentation for more information on the applet architecture.

## Patients

Patients are managed by `HRPeoplePickerViewController` and `HRPeopleSetupViewController`. The former controls which patient is selected and the order of patients. The later allows the user to download new patients and remove existing patients from the database.

Instances of `HRPeopleFeedViewController` can be shown in a popover to present a list of patients that are stored on the given RHEx server. Set the completion block to receive a callback when the user has made a selection.

## Security

Security is handled by `HRCryptoManager` and `CMDEncryptedSQLiteStore`. All data is encrypted using a shared application encryption key that is stored in the keychain encrypted with an application password. The password creation and verification happens in `HRAppDelegate`.

## User Interface

The hReader UI makes heavy use of iOS 5's view controller containment API.

The root controller of the app provides the "sliding panel" behavior as seen in Facebook.app, Gmail.app, Path.app, and others. An instance of `HRPanelViewController` is created and installed on application launch and is configured with an instance of `HRTabBarController` as the main content controller, and `HRPeoplePickerViewController` and `HRAppletConfigurationViewController` as accessory views. The `HRPanelViewController` handles all animation and presentation of the accessory and main content controllers.

 The main content controller controller &mdash; an instance of `HRTabBarController` &mdash; is meant to mimic `UITabBarController` in that it uses a series of tabs shown with a `UISegmentedControl` each segment of which shows the title of the child controller. It is responsible for creating the child controllers it will display, switching between them, and handling their view lifecycle.
 
 Each of the children of the tab controller are subclasses of `HRContentViewController`. This controller class is special in that it performs a lot of the work that needs to be done by controllers who wish to show patient data. It has helpers for displaying a patient image and a header banner, as is seen on the "Summary" and "Timeline" tabs of the app. Simply setting the `headerView`, `patientNameLabel`, and `patientImageView` properties on a subclass of `HRContentViewController` will let your controller display that information automatically. Additionally, overriding `reloadWithPatient:` will let you listen in on changes that happen to the object graph so that you can reload any additional UI elements that are shown.
 
 The most complex of these views is the patient summary view, represented by an instance of `HRPatientSummaryViewController`. It shows a lot of patient data as well as all installed applet tiles for the selected patient.
 

## Timeline

The timeline view is a web view that is written using the Angular MVC JavaScript framework. It can be found in `HReader/timeline-angular/app`. The view is represented by `HRTimelineViewController`, although instances of that class don't do much beyond loading the initial HTML and setting the viewed scope. The web contents talk to the native hReader application using instances of `NSURLProtocol`. The current pair of classes that handle communication are `HRTimelineGETURLProtocol` and `HRTimelinePOSTURLProtocol`.

The `GET` protocol is responsible for answering requests for JSON data at `http://hreader.local/timeline.json`. Requests to that endpoint must provide a `page` `GET` parameter that indicates the scope of data to retrieve. A final URL might look like this: `http://hreader.local/timeline.json?page=day`. This URL protocol calls out to Core Data in a thread-safe manner, fetches the current patient, and calls `timelineJSONPayloadWithStartDate:endDate:error:` on that patient to retrieve the desired JSON payload.

The `POST` protocol handles data that is posted by the user to the application. It creates instances of `HRMTimelineEntry` that are loose wrappers around a single JSON payload. Submitted payloads are meant to be echoed back to the timeline through the `GET` protocol the next time that endpoint is hit.

Each of these objects are registered automatically with the URL loading system by overriding `+ load`. Future subclasses of `NSURLProtocol` could be used to allow applets to communicate with the timeline or even applets to communicate with each other in a structured manner.

# Libraries

- **CMDManagedObject**: Wraps up some of the Core Data boiler plate code into an `NSManagedObject` subclass. It has helpers for generating fetch requests, creating instances in a given context, and single line fetches.
- **CMDActivityHUD**: Full-screen, blocking activity view that greys out the screen with a gradient. Used when performing operations that the user must wait on, like fetching OAuth tokens for the first time.
- **iMAS**: hReader relies on several libraries from the [iMAS](https://github.com/project-imas) project including an encrypted Core Data helper, cipher utilities, and encryption key management.
- **BlocksKit**: This small set of classes adds block helpers to a few common classes like `UIAlertView` and `UIActionSheet` to reduce the complexity of delegate callback code.