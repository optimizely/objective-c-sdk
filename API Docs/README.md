# Generate API Documentation
### Steps
* Download [doxygen]( http://www.stack.nl/~dimitri/doxygen/download.html) and open it.
* Move Doxygen.app to /Applications folder.
* Open Doxygen from Launchpad.
* Select **/Applications** folder in working directory.
* Select SDK root directory in source code directory.
* Select **objective-c-sdk/API Docs** in Destination Directory.
* In SDK root directory, execute **php docs/phpDocumentor.phar**
* This will generate HTML documentation in **docs/api** directory
* Browser **docs/api/index.html** in browser.

### Notes
* Tool: [**phpDocumentor**](https://www.phpdoc.org/)
* The configuration file ** phpdoc.dist.xml ** is placed in the root directory of SDK. Please see the configuration details [here](https://docs.phpdoc.org/references/configuration.html). 
* To view documentation errors. See ** /docs/api/reports/errors.html **
