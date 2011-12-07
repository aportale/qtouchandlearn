/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010, 2011 by Alessandro Portale
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

#include <QtGui>

#include "imageprovider.h"

class ImagePainter: public QWidget
{
    Q_PROPERTY(QString id READ id WRITE setId)

public:
    ImagePainter()
        : m_id(QLatin1String("object/elephant"))
    { }

    void paintEvent(QPaintEvent *event)
    {
        Q_UNUSED(event)
        QSize returnedSize;
        const QSize requestedSize = size();
        const QPixmap pixmap = m_imageProvider.requestPixmap(m_id, &returnedSize, requestedSize);
        QPainter p(this);
        p.drawPixmap(QPointF(0, 0), pixmap);
        qDebug() << "id:" << m_id << " requested:" << requestedSize << " returned:" << returnedSize;
    }

    QString id() const
    {
        return m_id;
    }

public slots:
    void setId(const QString &id)
    {
        m_id = id;
        update();
    }

private:
    QString m_id;
    ImageProvider m_imageProvider;
};

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    ImagePainter ip;
    ip.setId(QLatin1String("button/1"));
    ip.show();

    return app.exec();
}

