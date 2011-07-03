#include "feedback.h"
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
    ~VolumeKeyListener();
    virtual void MrccatoCommand(TRemConCoreApiOperationId aOperationId,
                                TRemConCoreApiButtonAction aButtonAct);

private:
    CRemConCoreApiTarget *m_iCoreTarget;
    CRemConInterfaceSelector *m_iInterfaceSelector;
    Feedback *m_feedback;
};

VolumeKeyListener::VolumeKeyListener(Feedback *feedback)
    : QObject(feedback)
    , m_feedback(feedback)
{
    QT_TRAP_THROWING(m_iInterfaceSelector = CRemConInterfaceSelector::NewL());
    QT_TRAP_THROWING(m_iCoreTarget = CRemConCoreApiTarget::NewL(*m_iInterfaceSelector, *this));
    m_iInterfaceSelector->OpenTargetL();
}

VolumeKeyListener::~VolumeKeyListener()
{
    delete m_iInterfaceSelector;
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
    , m_previousCorrectSound(0)
    , m_previousIncorrectSound(0)
    , m_audioVolume(100)
{
    new VolumeKeyListener(this);
}

Feedback::~Feedback()
{
    qDeleteAll(m_correctSounds);
    qDeleteAll(m_incorrectSounds);
}

static void playSound(const QList<QMediaPlayer*> &sounds, QMediaPlayer* &previousSound, int volume)
{
    if (sounds.isEmpty())
        return;

    QMediaPlayer *currentSound = 0;
    if (sounds.count() == 1) {
        currentSound = sounds.first();
    } else {
        do {
            const int index = qrand() % sounds.count();
            currentSound = sounds.at(index);
        } while (currentSound == previousSound);
        previousSound = currentSound;
    }
    currentSound->setVolume(volume);
    currentSound->stop();
    currentSound->play();
}

void Feedback::playCorrectSound() const
{
    playSound(m_correctSounds, m_previousCorrectSound, m_audioVolume);
}

void Feedback::playIncorrectSound() const
{
    playSound(m_incorrectSounds, m_previousIncorrectSound, m_audioVolume);
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

void Feedback::setAudioVolume(int volume, bool emitChangedSignal)
{
    m_audioVolume = qBound(0, volume, 100);
    if (emitChangedSignal)
        emit volumeChanged(m_audioVolume);
}
