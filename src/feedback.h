#ifndef FEEDBACK_H
#define FEEDBACK_H

#include <QtCore/QObject>
#include <QtCore/QVariant>

class QMediaPlayer;

class Feedback : public QObject
{
    Q_OBJECT

public:
    explicit Feedback(QObject *parent = 0);
    ~Feedback();

    Q_INVOKABLE void playCorrectSound() const;

    void init();
    int audioVolume() const;
    Q_INVOKABLE void setAudioVolume(int volume, bool emitChangedSignal = true);
    static void setDataPath(const QString &path);

signals:
    void volumeChanged(QVariant volume);

private:
    QList<QMediaPlayer*> m_correctSounds;
    mutable QMediaPlayer *m_previousCorrectSound;
    QList<QMediaPlayer*> m_incorrectSounds;
    mutable QMediaPlayer *m_previousIncorrectSound;
    int m_audioVolume;
};

#endif // FEEDBACK_H
