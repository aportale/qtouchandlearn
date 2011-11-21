#include <QtCore/QString>
#include <QtTest/QtTest>
#include <QtCore/QCoreApplication>

#include "imageprovider.h"

class RenderspeedTest : public QObject
{
    Q_OBJECT

public:
    RenderspeedTest();

private Q_SLOTS:
    void vignetteEffect();

private:
    ImageProvider m_imageProvider;
};

RenderspeedTest::RenderspeedTest()
{
    ImageProvider::init();
}

void RenderspeedTest::vignetteEffect()
{
    // Simulating a 360 x 640 pixels screen size
    const QSize requestedFrameSize(360, 322);
    const QSize requestedButtonSize(360, 106);
    QSize size;
    QBENCHMARK {
        m_imageProvider.requestPixmap(QLatin1String("frame/0"), &size, requestedFrameSize);
        m_imageProvider.requestPixmap(QLatin1String("button/0"), &size, requestedButtonSize);
        m_imageProvider.requestPixmap(QLatin1String("button/1"), &size, requestedButtonSize);
        m_imageProvider.requestPixmap(QLatin1String("button/2"), &size, requestedButtonSize);
    }
}

QTEST_MAIN(RenderspeedTest)

#include "tst_renderspeedtest.moc"
