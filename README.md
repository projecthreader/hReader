# Project Setup

- The build process requires the `plist` gem. Run `sudo gem install plist --no-rdoc --no-ri` to install the gem in your system Ruby.
- hReader relies on several git submodules. Run `git submodule update --init --recursive` to update all submodules.
- The build process requires the presence of the Xcode "Command Line Tools" package. Navigate to Xcode > Preferences > Downloads > Components and install the package.
- The build process requires openssl source code to be setup in the environment.
  - Download OpenSSL from <http://www.openssl.org/source/>. hReader has been tested against version 1.0.1c.
  - Untar the OpenSSL archive.
  - Create a new source tree in your Xcode preferences (Xcode > Preferences > Locations > Source Trees) called `OPENSSL_SRC` pointed at the location of the OpenSSL source directory.

# Version Control Policy

Please do not commit anything directly to `development` or `master`. Make commits to appropriately named feature branches off of development. Be sure to merge (or ideally regase) changes from `development` into your branch before you request that your branch be merged into the mainline branches. Only specified team members should merge from feature branches into mainline branches.

Feature branches should be pushed to gitorious so they can be worked on by multiple team members.

Please make commits as atomic as possible (do not wait until the end of the day to commit everything, this isn't SVN). This makes merging and rebasing easier on everyone.
