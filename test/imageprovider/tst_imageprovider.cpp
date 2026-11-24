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

#include <QtCore/QRegularExpression>
#include <QtCore/QThread>
#include <QtGui/QImage>
#include <QtTest/QTest>

#include <atomic>
#include <memory>

#include "imageprovider.h"

using namespace Qt::StringLiterals;

// How an image's size relates to the requested size
enum class Fit {
    Exactly, // Same size
    Inside, // Keeps the aspect ratio, touches the requested size from the inside
    Covering, // Keeps the aspect ratio, touches the requested size from the outside
    Within, // Not larger
};

// The sizes in the app on a 1080 x 2400 phone in portrait
static const QSize exerciseImageSize(1080, 1080);
static const QSize answerButtonSize(1080, 330);

class tst_ImageProvider : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();

    void imageSize_data();
    void imageSize();
    void objects_data();
    void objects();
    void lessonIcons_data();
    void lessonIcons();
    void invalidRequests_data();
    void invalidRequests();
    void concurrentRequests();

    void benchmark_data();
    void benchmark();
    void benchmarkUncachedVignette_data();
    void benchmarkUncachedVignette();
    void benchmarkFirstRenderInNewThread_data();
    void benchmarkFirstRenderInNewThread();

private:
    QImage request(const QString &id, const QSize &requestedSize);

    ImageProvider m_provider;
};

static bool hasVisiblePixels(const QImage &image)
{
    for (int y = 0; y < image.height(); ++y) {
        for (int x = 0; x < image.width(); ++x) {
            if (qAlpha(image.pixel(x, y)) > 0)
                return true;
        }
    }
    return false;
}

QImage tst_ImageProvider::request(const QString &id, const QSize &requestedSize)
{
    QSize size;
    return m_provider.requestImage(id, &size, requestedSize);
}

void tst_ImageProvider::initTestCase()
{
    ImageProvider::init();
}

void tst_ImageProvider::imageSize_data()
{
    QTest::addColumn<QString>("id");
    QTest::addColumn<QSize>("requestedSize");
    QTest::addColumn<Fit>("fit");

    QTest::newRow("background") << u"background/background_01"_s << QSize(400, 300) << Fit::Covering;
    QTest::newRow("title text mask") << u"title/textmask"_s << QSize(400, 100) << Fit::Inside;
    // The spectrum is always 360 pixels wide
    QTest::newRow("title spectrum") << u"title/spectrum"_s << QSize(360, 40) << Fit::Exactly;
    QTest::newRow("special button") << u"specialbutton/backbutton"_s << QSize(100, 80) << Fit::Exactly;
    QTest::newRow("button, landscape") << u"button/0"_s << QSize(400, 120) << Fit::Exactly;
    QTest::newRow("button, portrait") << u"button/2"_s << QSize(120, 400) << Fit::Exactly;
    QTest::newRow("frame") << u"frame/0"_s << QSize(400, 300) << Fit::Exactly;
    QTest::newRow("object") << u"object/robot"_s << QSize(300, 300) << Fit::Inside;
    QTest::newRow("clock") << u"clock/9/45/0"_s << QSize(300, 300) << Fit::Inside;
    QTest::newRow("clock, other variation") << u"clock/12/5/1"_s << QSize(300, 200) << Fit::Inside;
    QTest::newRow("notes") << u"notes/C,D sharp,E flat"_s << QSize(600, 200) << Fit::Inside;
    QTest::newRow("quantity, 1") << u"quantity/1/apple"_s << QSize(300, 300) << Fit::Within;
    QTest::newRow("quantity, 20") << u"quantity/20/fish"_s << QSize(300, 300) << Fit::Within;
    QTest::newRow("quantity, balloons") << u"quantity/7/balloon"_s << QSize(300, 200) << Fit::Within;
    QTest::newRow("lesson icon") << u"lessonicon/Read/0"_s << QSize(300, 312) << Fit::Exactly;
    QTest::newRow("color") << u"color/#FFE800/0"_s << QSize(300, 300) << Fit::Inside;
}

void tst_ImageProvider::imageSize()
{
    QFETCH(QString, id);
    QFETCH(QSize, requestedSize);
    QFETCH(Fit, fit);

    const QImage image = request(id, requestedSize);
    QVERIFY(!image.isNull());
    QVERIFY(hasVisiblePixels(image));

    const QSize size = image.size();
    const bool touches = size.width() == requestedSize.width() || size.height() == requestedSize.height();
    switch (fit) {
    case Fit::Exactly:
        QCOMPARE(size, requestedSize);
        break;
    case Fit::Inside:
        QVERIFY2(size.width() <= requestedSize.width() && size.height() <= requestedSize.height() && touches,
                 qPrintable(u"%1x%2"_s.arg(size.width()).arg(size.height())));
        break;
    case Fit::Covering:
        QVERIFY2(size.width() >= requestedSize.width() && size.height() >= requestedSize.height() && touches,
                 qPrintable(u"%1x%2"_s.arg(size.width()).arg(size.height())));
        break;
    case Fit::Within:
        QVERIFY2(size.width() <= requestedSize.width() && size.height() <= requestedSize.height(),
                 qPrintable(u"%1x%2"_s.arg(size.width()).arg(size.height())));
        break;
    }
}

void tst_ImageProvider::objects_data()
{
    QTest::addColumn<QString>("object");

    // The objects of exercises.cpp
    for (const char *object : { "banana", "elephant", "robot", "flower", "fish", "rooster", "airplane",
                                "candle", "scissors", "key", "horse", "dog", "cat", "camel", "crocodile",
                                "pig", "snake", "giraffe", "snail", "hedgehog" }) {
        QTest::newRow(object) << QString::fromLatin1(object);
    }
}

void tst_ImageProvider::objects()
{
    QFETCH(QString, object);

    const QImage image = request(u"object/"_s + object, QSize(300, 300));
    QVERIFY(!image.isNull());
    QVERIFY(hasVisiblePixels(image));
}

void tst_ImageProvider::lessonIcons_data()
{
    QTest::addColumn<QString>("lesson");

    // The groups and lessons of lessons.cpp
    for (const char *lesson : { "Read", "Count", "Clock", "Music", "Color", "Mixed",
                                "FirstLetter", "NameTerms", "CountEasy", "CountReadEasy", "CountHard",
                                "CountReadHard", "ClockEasy", "ClockMedium", "ClockHard", "NotesReadEasy",
                                "NotesReadHard", "ColorEasy", "MixedEasy", "MixedMedium", "MixedHard" }) {
        QTest::newRow(lesson) << QString::fromLatin1(lesson);
    }
}

void tst_ImageProvider::lessonIcons()
{
    QFETCH(QString, lesson);

    // Without the icon in the SVG, a lesson icon is only the button.
    const QSize size(300, 312);
    const QImage icon = request(u"lessonicon/"_s + lesson + u"/0"_s, size);
    QCOMPARE(icon.size(), size);
    QEXPECT_FAIL("ColorEasy", "Not drawn yet. Only the options screen shows it, and groups with "
                 "one lesson have none.", Continue);
    QVERIFY(icon != request(u"button/0"_s, size));
}

void tst_ImageProvider::invalidRequests_data()
{
    QTest::addColumn<QString>("id");
    QTest::addColumn<QSize>("requestedSize");

    const QSize size(100, 100);
    QTest::newRow("empty") << QString() << size;
    QTest::newRow("no element") << u"button"_s << size;
    QTest::newRow("unknown kind") << u"nosuchkind/x"_s << size;
    QTest::newRow("clock, too few parameters") << u"clock/9/45"_s << size;
    QTest::newRow("quantity, too few parameters") << u"quantity/5"_s << size;
    QTest::newRow("lesson icon, too few parameters") << u"lessonicon/Read"_s << size;
    QTest::newRow("color, too few parameters") << u"color/#FFFFFF"_s << size;
    QTest::newRow("zero width") << u"button/0"_s << QSize(0, 100);
    // An Image without sourceSize requests this
    QTest::newRow("invalid size") << u"button/0"_s << QSize(-1, -1);
}

void tst_ImageProvider::invalidRequests()
{
    QFETCH(QString, id);
    QFETCH(QSize, requestedSize);

    // Each invalid request prints why.
    QTest::ignoreMessage(QtWarningMsg, QRegularExpression(u"^ImageProvider: "_s));
    QVERIFY(request(id, requestedSize).isNull());
}

// The asynchronous exercise images render in Qt Quick's image reader thread, at the same time
// as the GUI thread renders the others. This failed when the threads shared the SVG renderers.
void tst_ImageProvider::concurrentRequests()
{
    const QStringList ids = {
        u"clock/9/45/0"_s, u"color/#FFE800/0"_s, u"button/1"_s, u"frame/0"_s,
        u"background/background_01"_s, u"object/robot"_s, u"notes/A sharp"_s, u"lessonicon/Clock/1"_s,
    };
    const QSize size(300, 300);
    QList<QImage> expected;
    for (const QString &id : ids)
        expected.append(request(id, size));

    std::atomic<int> mismatches = 0;
    const auto renderAll = [&](int offset) {
        for (int round = 0; round < 100; ++round) {
            for (int i = 0; i < ids.size(); ++i) {
                const int index = (i + offset) % ids.size();
                if (request(ids.at(index), size) != expected.at(index))
                    ++mismatches;
            }
        }
    };
    std::unique_ptr<QThread> thread(QThread::create(renderAll, int(ids.size() / 2)));
    thread->start();
    renderAll(0);
    thread->wait();
    QCOMPARE(mismatches.load(), 0);
}

void tst_ImageProvider::benchmark_data()
{
    QTest::addColumn<QString>("id");
    QTest::addColumn<QSize>("requestedSize");

    QTest::newRow("background") << u"background/background_01"_s << QSize(1944, 324);
    QTest::newRow("frame") << u"frame/0"_s << exerciseImageSize;
    QTest::newRow("button") << u"button/1"_s << answerButtonSize;
    QTest::newRow("lesson icon") << u"lessonicon/Clock/0"_s << QSize(540, 562);
    QTest::newRow("object") << u"object/robot"_s << exerciseImageSize;
    QTest::newRow("quantity, 20") << u"quantity/20/fish"_s << exerciseImageSize;
    QTest::newRow("clock") << u"clock/9/45/0"_s << exerciseImageSize;
    QTest::newRow("notes") << u"notes/A sharp"_s << exerciseImageSize;
    QTest::newRow("color") << u"color/#FFE800/0"_s << exerciseImageSize;
}

void tst_ImageProvider::benchmark()
{
    QFETCH(QString, id);
    QFETCH(QSize, requestedSize);

    QVERIFY(!request(id, requestedSize).isNull());
    QBENCHMARK {
        request(id, requestedSize);
    }
}

void tst_ImageProvider::benchmarkUncachedVignette_data()
{
    QTest::addColumn<QString>("id");
    QTest::addColumn<QSize>("requestedSize");

    QTest::newRow("frame") << u"frame/0"_s << exerciseImageSize;
    QTest::newRow("button") << u"button/1"_s << answerButtonSize;
}

// Buttons and frames reuse the vignette of the previous size. Alternating sizes draws it each time.
void tst_ImageProvider::benchmarkUncachedVignette()
{
    QFETCH(QString, id);
    QFETCH(QSize, requestedSize);

    QVERIFY(!request(id, requestedSize).isNull());
    int iteration = 0;
    QBENCHMARK {
        request(id, requestedSize + QSize(0, ++iteration % 2));
    }
}

void tst_ImageProvider::benchmarkFirstRenderInNewThread_data()
{
    QTest::addColumn<QString>("id");

    QTest::newRow("object") << u"object/robot"_s;
    QTest::newRow("quantity") << u"quantity/5/apple"_s;
    QTest::newRow("clock") << u"clock/9/45/0"_s;
    QTest::newRow("notes") << u"notes/A sharp"_s;
    QTest::newRow("color") << u"color/#FFE800/0"_s;
}

// A new thread loads its own SVG renderers first. Includes starting the thread.
void tst_ImageProvider::benchmarkFirstRenderInNewThread()
{
    QFETCH(QString, id);

    QImage image;
    QBENCHMARK {
        std::unique_ptr<QThread> thread(QThread::create([&] { image = request(id, exerciseImageSize); }));
        thread->start();
        thread->wait();
    }
    QVERIFY(!image.isNull());
}

QTEST_MAIN(tst_ImageProvider)

#include "tst_imageprovider.moc"
