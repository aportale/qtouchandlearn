#include "feedback.h"
#include <QtDebug>
#include <QtCore/QDir>

static QString dataPath = QLatin1String("data");

Feedback::Feedback(QObject *parent)
    : QObject(parent)
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
    m_correctSounds.at(index)->stop();
    m_correctSounds.at(index)->play();
}

void Feedback::init()
{
    QDir path(dataPath);
    foreach (const QFileInfo &midiFile, path.entryInfoList(QStringList(QLatin1String("*.mid")), QDir::Files)) {
        if (midiFile.fileName().startsWith(QLatin1String("correct")))
            m_correctSounds.append(new QSound(midiFile.absoluteFilePath()));
        else if (midiFile.fileName().startsWith(QLatin1String("incorrect")))
            m_incorrectSounds.append(new QSound(midiFile.absoluteFilePath()));
    }
}

void Feedback::setDataPath(const QString &path)
{
    dataPath = path;
}
