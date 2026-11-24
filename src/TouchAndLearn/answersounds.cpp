/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2026 by Alessandro Portale
    http://touchandlearn.sourceforge.net

    This file is part of Touch'n'learn

    Touch'n'learn is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Touch'n'learn is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Touch'n'learn; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
*/

#include "answersounds.h"

#include <QtCore/QRandomGenerator>
#include <QtCore/QSettings>
#include <QtCore/QString>

using namespace Qt::StringLiterals;

// Without Qt Multimedia, WebAssembly builds play the sounds with the Web Audio API.
#if !defined(TOUCHANDLEARN_USE_QTMULTIMEDIA) && defined(Q_OS_WASM)
#define TOUCHANDLEARN_USE_WEBAUDIO
#endif

#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
#include <QtMultimedia/QSoundEffect>
#endif

#ifdef TOUCHANDLEARN_USE_WEBAUDIO
#include <QtCore/QDebug>
#include <QtCore/QFile>
#include <QtQml/QQmlFile>

#include <emscripten.h>

// The JavaScript side of the Web Audio backend: one AudioContext, decoded audio by Sound id.

// Decodes the audio file in data, and stores it under id. Replaces an earlier sound of id.
EM_JS(void, touchandlearn_loadSound, (int id, const char *data, int size), {
    if (!Module.touchAndLearnAudio) {
        // "playback" (Safari 17+) plays even in iOS silent mode, which mutes Web Audio by
        // default. It also pauses the music of other apps while a sound plays.
        if (navigator.audioSession)
            navigator.audioSession.type = "playback";
        const context = new AudioContext();
        // The context stays suspended until the user interacts. Resume it in the capture phase
        // (before Qt's handlers) of each interaction, also after interruptions like iOS calls.
        const resume = function() {
            if (context.state !== "running")
                context.resume();
        };
        // HTML standard activation events. Some browsers resume a context only during these.
        const activationEvents = ["pointerdown", "pointerup", "touchend", "keydown"];
        for (const type of activationEvents)
            document.addEventListener(type, resume, true);
        Module.touchAndLearnAudio = { context: context, sounds: new Map() };
    }
    const audio = Module.touchAndLearnAudio;
    // decodeAudioData takes over the buffer, so pass a copy. Undecodable sounds resolve to null.
    const bytes = HEAPU8.slice(data, data + size);
    const decoded = audio.context.decodeAudioData(bytes.buffer).catch(function(error) {
        console.warn("Could not decode sound:", error);
        return null;
    });
    audio.sounds.set(id, decoded);
});

// Plays the sound of id with the volume from 0 to 1. Waits until it is decoded.
EM_JS(void, touchandlearn_playSound, (int id, double volume), {
    const audio = Module.touchAndLearnAudio;
    const decoded = audio && audio.sounds.get(id);
    if (!decoded)
        return;
    decoded.then(function(buffer) {
        if (!buffer)
            return;
        const source = audio.context.createBufferSource();
        source.buffer = buffer;
        const gain = audio.context.createGain();
        gain.gain.value = volume;
        source.connect(gain).connect(audio.context.destination);
        source.start();
    });
});

// Removes the sound of id.
EM_JS(void, touchandlearn_unloadSound, (int id), {
    if (Module.touchAndLearnAudio)
        Module.touchAndLearnAudio.sounds.delete(id);
});

static int lastSoundId = 0;
#endif // TOUCHANDLEARN_USE_WEBAUDIO

// A short sound, played by QSoundEffect or Web Audio, depending on the build. Otherwise silent.
class Sound : public QObject
{
public:
    explicit Sound(QObject *parent = nullptr);
    ~Sound() override;

    QUrl source() const;
    void setSource(const QUrl &source);

    // The volume from 0 to 1.
    qreal volume() const;
    void setVolume(qreal volume);

    void play();

private:
    QUrl m_source;
    qreal m_volume = 1;
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    QSoundEffect *m_soundEffect;
#endif
#ifdef TOUCHANDLEARN_USE_WEBAUDIO
    // The key of the decoded sound on the JavaScript side.
    int m_id;
#endif
};

Sound::Sound(QObject *parent)
    : QObject(parent)
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    , m_soundEffect(new QSoundEffect(this))
#endif
#ifdef TOUCHANDLEARN_USE_WEBAUDIO
    , m_id(++lastSoundId)
#endif
{
}

Sound::~Sound()
{
#ifdef TOUCHANDLEARN_USE_WEBAUDIO
    touchandlearn_unloadSound(m_id);
#endif
}

QUrl Sound::source() const
{
    return m_source;
}

void Sound::setSource(const QUrl &source)
{
    if (source == m_source)
        return;
    m_source = source;
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    m_soundEffect->setSource(source);
#endif
#ifdef TOUCHANDLEARN_USE_WEBAUDIO
    touchandlearn_unloadSound(m_id);
    if (!source.isEmpty()) {
        QFile file(QQmlFile::urlToLocalFileOrQrc(source));
        if (file.open(QIODevice::ReadOnly)) {
            const QByteArray data = file.readAll();
            touchandlearn_loadSound(m_id, data.constData(), int(data.size()));
        } else {
            qWarning() << "Could not open sound" << source << file.errorString();
        }
    }
#endif
}

qreal Sound::volume() const
{
    return m_volume;
}

void Sound::setVolume(qreal volume)
{
    if (volume == m_volume)
        return;
    m_volume = volume;
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    m_soundEffect->setVolume(volume);
#endif
}

void Sound::play()
{
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    m_soundEffect->play();
#endif
#ifdef TOUCHANDLEARN_USE_WEBAUDIO
    touchandlearn_playSound(m_id, m_volume);
#endif
}

RandomSound::RandomSound(const QList<QUrl> &sources, QObject *parent)
{
    for (const QUrl &source : sources) {
        auto sound = new Sound(parent);
        sound->setSource(source);
        m_sounds.append(sound);
    }
}

void RandomSound::play(qreal volume)
{
    const int count = int(m_sounds.size());
    if (count == 0)
        return;
    // Skip the previous variant's index, unless there is only one variant.
    const bool skipPrevious = m_previousIndex >= 0 && count > 1;
    int index = QRandomGenerator::global()->bounded(skipPrevious ? count - 1 : count);
    if (skipPrevious && index >= m_previousIndex)
        ++index;
    m_previousIndex = index;
    Sound *sound = m_sounds.at(index);
    sound->setVolume(volume);
    sound->play();
}

static const char volumeSettingsKey[] = "Config/Volume";

// The URLs of the WAV files in the resources of the QML module, in data/audio.
static QList<QUrl> audioUrls(const QString &prefix, int count)
{
    QList<QUrl> result;
    for (int i = 1; i <= count; ++i) {
        result.append(QUrl(u"qrc:/qt/qml/TouchAndLearn/data/audio/%1_%2.wav"_s
                               .arg(prefix)
                               .arg(i, 2, 10, u'0')));
    }
    return result;
}

AnswerSounds::AnswerSounds(QObject *parent)
    : QObject(parent)
    , m_correctSounds(audioUrls(u"correctanswer"_s, 5), this)
    , m_incorrectSounds(audioUrls(u"incorrectanswer"_s, 4), this)
    , m_volume(qBound(0, QSettings().value(volumeSettingsKey, 80).toInt(), 100))
{
}

int AnswerSounds::volume() const
{
    return m_volume;
}

void AnswerSounds::setVolume(int volume)
{
    volume = qBound(0, volume, 100);
    if (volume == m_volume)
        return;
    m_volume = volume;
    QSettings().setValue(volumeSettingsKey, volume);
    emit volumeChanged();
}

void AnswerSounds::playCorrect()
{
    m_correctSounds.play(m_volume / 100.0);
}

void AnswerSounds::playIncorrect()
{
    m_incorrectSounds.play(m_volume / 100.0);
}
