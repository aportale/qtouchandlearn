#ifndef FEEDBACK_H
#define FEEDBACK_H

#include <QtGui/QSound>

class Feedback : public QObject
{
    Q_OBJECT
public:
    explicit Feedback(QObject *parent = 0);
    ~Feedback();

    Q_INVOKABLE void playCorrectSound() const;

    void init();
    static void setDataPath(const QString &path);

private:
    QList<QSound*> m_correctSounds;
    QList<QSound*> m_incorrectSounds;
};

#endif // FEEDBACK_H
