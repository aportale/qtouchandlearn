#include "feedback.h"
#include <QtDebug>
#include <QtCore/QDir>

#if defined(Q_OS_SYMBIAN)
#include <QMediaPlayer>

static QString dataPath = QLatin1String("data");

Feedback::Feedback(QObject *parent)
    : QObject(parent)
    , audioVolume(100)
{
}

Feedback::~Feedback()
{
    qDeleteAll(m_correctSounds);
    qDeleteAll(m_incorrectSounds);
}

void Feedback::playCorrectSound() const
{
    Q_ASSERT(!m_correctSounds.isEmpty());
    const int index = qrand() % m_correctSounds.count();
    QMediaPlayer *player = m_correctSounds.at(index);
    player->stop();
    player->play();
}

static QMediaPlayer *player(const QString &file)
{
    QMediaPlayer *result = new QMediaPlayer;
    QMediaContent content(QUrl::fromLocalFile(file));
    result->setMedia(content);
    return result;
}

void Feedback::init()
{
    QDir path(dataPath);
    foreach (const QFileInfo &midiFile, path.entryInfoList(QStringList(QLatin1String("*.mid")), QDir::Files)) {
        if (midiFile.fileName().startsWith(QLatin1String("correct")))
            m_correctSounds.append(player(midiFile.absoluteFilePath()));
        else if (midiFile.fileName().startsWith(QLatin1String("incorrect")))
            m_incorrectSounds.append(player(midiFile.absoluteFilePath()));
    }
}

void Feedback::setDataPath(const QString &path)
{
    dataPath = path;
}

#else // Q_OS_SYMBIAN

Feedback::Feedback(QObject *parent)
    : QObject(parent)
    , audioVolume(100)
{
}

Feedback::~Feedback()
{
}

void Feedback::playCorrectSound() const
{
}

void Feedback::init()
{
}

void Feedback::setDataPath(const QString &path)
{
}

#endif // Q_OS_SYMBIAN
