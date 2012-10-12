# hReader

hReader is an open-source, patient-centric mobile health data manager that securely provides patients and their families with their complete health information.

# Project Setup

- The build process requires the `plist` gem. Run `sudo gem install plist --no-rdoc --no-ri` to install the gem in your system Ruby.
- hReader relies on several git submodules. Run `git submodule update --init --recursive` to update all submodules.
- The build process requires the presence of the Xcode "Command Line Tools" package. Navigate to Xcode > Preferences > Downloads > Components and install the package.
- The build process requires openssl source code to be setup in the environment.
  - Download OpenSSL from <http://www.openssl.org/source/>. hReader has been tested against version 1.0.1c.
  - Untar the OpenSSL archive.
  - Create a new source tree in your Xcode preferences (Xcode > Preferences > Locations > Source Trees) called `OPENSSL_SRC` pointed at the location of the OpenSSL source directory.
