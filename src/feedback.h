#ifndef FEEDBACK_H
#define FEEDBACK_H

#include <QtCore/QObject>

class QMediaPlayer;

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
    QList<QMediaPlayer*> m_correctSounds;
    QList<QMediaPlayer*> m_incorrectSounds;
    int audioVolume;
};

#endif // FEEDBACK_H
