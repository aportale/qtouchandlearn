#include "feedback.h"
#include <QtGui/QSound>
#include <QtDebug>

static QString dataPath = QLatin1String("data");

Q_GLOBAL_STATIC_WITH_ARGS(QSound, correctSound, (dataPath + QLatin1String("/correctanswer.mid")));

Feedback::Feedback(QObject *parent)
    : QObject(parent)
{
}

void Feedback::playCorrectSound() const
{
    correctSound()->stop();
    correctSound()->play();
}

void Feedback::init()
{
    correctSound();
}

void Feedback::setDataPath(const QString &path)
{
    dataPath = path;
}
