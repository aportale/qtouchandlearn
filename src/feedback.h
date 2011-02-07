#ifndef FEEDBACK_H
#define FEEDBACK_H

#include <QObject>

class Feedback : public QObject
{
    Q_OBJECT
public:
    explicit Feedback(QObject *parent = 0);

    Q_INVOKABLE void playCorrectSound() const;

    static void init();
    static void setDataPath(const QString &path);
};

#endif // FEEDBACK_H
