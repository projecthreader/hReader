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

Each patient stores a list of applets that the user has configured. Available applets are loaded from `HReaderApplets.plist` can be accessed through `HRAppletConfigurationViewController`.

## Patients

Patients are managed by `HRPeoplePickerViewController` and `HRPeopleSetupViewController`. The former controls which patient is selected and the order of patients. The later allows the user to download new patients and remove existing patients from the database.

Instances of `HRPeopleFeedViewController` can be shown in a popover to present a list of patients that are stored on the given RHEx server. Set the completion block to receive a callback when the user has made a selection.

## Security

Security is handled by `HRCryptoManager` and `CMDEncryptedSQLiteStore`. All data is encrypted using a shared application encryption key that is stored in the keychain encrypted with an application password. The password creation and verification happens in `HRAppDelegate`.
