MTViewController

Copyright Mekentosj 2010. All rights reserved.

Contact: http://mekentosj.com (charles.parnot@gmail.com)

Description
-----------

The MTViewController class is a subclass of  NSViewController that ensures automatic insertion of the view controller into the responder chain. The MTViewController class is meant to be subclassed, so you don't have to worry about the responder chain anymore: the view controller is guaranteed to be automatically inserted between the controlled NSView and the next responder that it would normally have in the absence of the view controller. A diagram is worth a thousand words:

	without MTViewController:   responder X  -->  view  -->  Responder Y
	   with MTViewController:   responder X  -->  view  -->  view controller -->  Responder Y


License
-------

The MTViewController class and the example code are released under the modified BSD License. Please read the text of the license included with the project for more details.



Changelog
---------

August 2010

* First public release
