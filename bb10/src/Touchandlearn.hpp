// Default empty project template
#ifndef Touchandlearn_HPP_
#define Touchandlearn_HPP_

#include <QObject>

namespace bb { namespace cascades { class Application; }}

/*!
 * @brief Application pane object
 *
 *Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */
class Touchandlearn : public QObject
{
    Q_OBJECT
public:
    Touchandlearn(bb::cascades::Application *app);
    virtual ~Touchandlearn() {}
};


#endif /* Touchandlearn_HPP_ */
