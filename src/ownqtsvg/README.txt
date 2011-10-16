This is a copy of the QtSvg module from Qt version 4.7.4.
It is used on platforms where Qt comes without QtSvg.

The Svg generation, aswell as the QWidget and
QGraphicsViewItem have been stripped out.

The copied sources are minimally modified in order not to
use private Qt Api. Therefore, css-style support has been
removed, since it required the private stylesheet classes.
To convert an Svg file from css to xml style (which is by
the way faster to parse), the tool "Scour" can be used.
   http://www.codedread.com/scour/
