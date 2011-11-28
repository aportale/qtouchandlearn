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
    void exerciseImages();
    void exerciseImages_data();

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

void RenderspeedTest::exerciseImages()
{
    QFETCH(QString, id);
    // Simulating a 360 x 640 pixels screen size
    const QSize requestedFrameSize(360, 322);
    QSize size;
    QBENCHMARK {
        m_imageProvider.requestPixmap(id, &size, requestedFrameSize);
    }
}

void RenderspeedTest::exerciseImages_data()
{
    QTest::addColumn<QString>("id");
    QTest::newRow("Read (Robot)") << QString::fromLatin1("object/robot");
    QTest::newRow("Count (20 Fishes)") << QString::fromLatin1("quantity/20/fish");
    QTest::newRow("Clock") << QString::fromLatin1("clock/9/45/0");
    QTest::newRow("Music (a sharp)") << QString::fromLatin1("notes/a sharp");
    QTest::newRow("Color (Yellow)") << QString::fromLatin1("color/#FF0/0");
}

QTEST_MAIN(RenderspeedTest)

#include "tst_renderspeedtest.moc"
