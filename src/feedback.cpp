#include "feedback.h"
#include <QtDebug>
#include <QtCore/QDir>

static QString dataPath = QLatin1String("data");

#if defined(Q_OS_SYMBIAN)
#include <QMediaPlayer>
#include <remconcoreapitargetobserver.h>    // link against RemConCoreApi.lib
#include <remconcoreapitarget.h>            // and
#include <remconinterfaceselector.h>        // RemConInterfaceBase.lib

class VolumeKeyListener : public QObject, public MRemConCoreApiTargetObserver
{
public:
    VolumeKeyListener(Feedback *feedback);
    virtual void MrccatoCommand(TRemConCoreApiOperationId aOperationId,
                                TRemConCoreApiButtonAction aButtonAct);

private:
    QScopedPointer <CRemConInterfaceSelector> m_iInterfaceSelector;
    QScopedPointer <CRemConCoreApiTarget> m_iCoreTarget;
    Feedback *m_feedback;
};

VolumeKeyListener::VolumeKeyListener(Feedback *feedback)
    : QObject(feedback)
    , m_feedback(feedback)
{
    QT_TRAP_THROWING(m_iInterfaceSelector.reset(CRemConInterfaceSelector::NewL()));
    QT_TRAP_THROWING(m_iCoreTarget.reset(CRemConCoreApiTarget::NewL(*m_iInterfaceSelector, *this)));
    m_iInterfaceSelector->OpenTargetL();
}

void VolumeKeyListener::MrccatoCommand(TRemConCoreApiOperationId aOperationId,
                                       TRemConCoreApiButtonAction aButtonAct)
{
    Q_UNUSED(aButtonAct)
    switch(aOperationId) {
    case ERemConCoreApiVolumeUp:
        m_feedback->setAudioVolume(m_feedback->audioVolume() + 20);
        break;
    case ERemConCoreApiVolumeDown:
        m_feedback->setAudioVolume(m_feedback->audioVolume() - 20);
        break;
    default:
        break;
    }
}

Feedback::Feedback(QObject *parent)
    : QObject(parent)
    , m_audioVolume(100)
{
    new VolumeKeyListener(this);
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
    player->setVolume(m_audioVolume);
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

#else // Q_OS_SYMBIAN

#include <QtGui/QShortcut>
#include <QtGui/QApplication>
#include <QtCore/QTimer>

class VolumeKeyListener : public QObject
{
    Q_OBJECT

public:
    VolumeKeyListener(Feedback *feedback);

private slots:
    void setupShortcuts();
    void volumeUp();
    void volumeDown();

private:
    Feedback *m_feedback;
};

VolumeKeyListener::VolumeKeyListener(Feedback *feedback)
    : QObject(feedback)
    , m_feedback(feedback)
{
    // Using a timer because shortcuts need a widget pointer, which may not yet exist at this moment.
    QTimer::singleShot(0, this, SLOT(setupShortcuts()));
}

void VolumeKeyListener::setupShortcuts()
{
    QShortcut *volumeUp = new QShortcut(QKeySequence(Qt::Key_Plus), qApp->activeWindow());
    connect(volumeUp, SIGNAL(activated()), SLOT(volumeUp()));

    QShortcut *volumeDown = new QShortcut(QKeySequence(Qt::Key_Minus), qApp->activeWindow());
    connect(volumeDown, SIGNAL(activated()), SLOT(volumeDown()));
}

void VolumeKeyListener::volumeUp()
{
    m_feedback->setAudioVolume(m_feedback->audioVolume() + 20);
}

void VolumeKeyListener::volumeDown()
{
    m_feedback->setAudioVolume(m_feedback->audioVolume() - 20);
}

Feedback::Feedback(QObject *parent)
    : QObject(parent)
    , m_audioVolume(100)
{
    new VolumeKeyListener(this);
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

#include "feedback.moc"

#endif // Q_OS_SYMBIAN

void Feedback::setDataPath(const QString &path)
{
    dataPath = path;
}

int Feedback::audioVolume() const
{
    return m_audioVolume;
}

void Feedback::setAudioVolume(int volume)
{
    m_audioVolume = qBound(0, volume, 100);
    emit volumeChanged(m_audioVolume);
}
