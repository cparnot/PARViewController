PARViewController

Contact: charles.parnot@gmail.com

Description
-----------

The PARViewController class is a subclass of  NSViewController that ensures automatic insertion of the view controller into the responder chain. The PARViewController class is meant to be subclassed, so you don't have to worry about the responder chain anymore: the view controller is guaranteed to be automatically inserted between the controlled NSView and the next responder that it would normally have in the absence of the view controller. A diagram is worth a thousand words:

	without PARViewController:   responder X  -->  view  -->  Responder Y
	   with PARViewController:   responder X  -->  view  -->  view controller -->  Responder Y

Note that this is only useful when targeting a version older than OS X 10.10 Yosemite. When targeting OS X 10.10 or older, NSViewController instances are automatically inserted into the responder chain.



License
-------

The PARViewController class and the example code are released under the modified BSD License. Please read the text of the license included with the project for more details.



Changelog
---------

Jan 2013

* Changing class prefix to PAR

Oct 2011

* Project updated to Xcode 4.2
* ARC compatibility

August 2010

* First public release
