/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010 by Alessandro Portale
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

#include "imageprovider.h"
#include "qglobal.h"
#include <math.h>
#include <QSvgRenderer>
#include <QPainter>
#include <QtDebug>

const QString frameString = QLatin1String("frame");
const QString buttonString = QLatin1String("button");

Q_GLOBAL_STATIC_WITH_INITIALIZER(QSvgRenderer, designRenderer, {
    x->load(QLatin1String("data/design.svg"));
});

Q_GLOBAL_STATIC_WITH_INITIALIZER(QSvgRenderer, objectRenderer, {
    x->load(QLatin1String("data/objects.svg"));
});

Q_GLOBAL_STATIC_WITH_INITIALIZER(QSvgRenderer, countablesRenderer, {
    x->load(QLatin1String("data/countables.svg"));
});

struct ElementVariations
{
    QStringList elementIds;
    qreal widthToHeightRatio;
    inline bool operator<(const ElementVariations &other) const
    {
        return widthToHeightRatio < other.widthToHeightRatio;
    }
};

typedef QList<ElementVariations> ElementVariationList;

ElementVariationList elementsWithSizes(const QString &elementBase)
{
    ElementVariationList result;
    QSvgRenderer *renderer = designRenderer();
    ElementVariations element;
    element.widthToHeightRatio = -1;
    for (int i = 1; ; i++) {
        const QString id = elementBase + QLatin1Char('_') + QString::number(i);
        if (!renderer->elementExists(id))
            break;
        const QSizeF size = renderer->boundsOnElement(id).size();
        const qreal widthToHeightRatio = size.width() / size.height();
        if (!qFuzzyCompare(widthToHeightRatio, element.widthToHeightRatio)) {
            if (element.widthToHeightRatio > 0) // Check, is it is the first element
                result.append(element);
            element.widthToHeightRatio = widthToHeightRatio;
            element.elementIds.clear();
        }
        element.elementIds.append(id);
    }
    if (!element.elementIds.isEmpty())
        result.append(element);
    qSort(result);
    return result;
}

Q_GLOBAL_STATIC_WITH_INITIALIZER(ElementVariationList, buttonVariations, {
    x->append(elementsWithSizes(buttonString));
});

Q_GLOBAL_STATIC_WITH_INITIALIZER(ElementVariationList, frameVariations, {
    x->append(elementsWithSizes(frameString));
});

ImageProvider::ImageProvider()
    : QDeclarativeImageProvider(QDeclarativeImageProvider::Pixmap)
{
}

inline static QPixmap quantity(int quantity, const QString &item, QSize *size, const QSize &requestedSize)
{
    QSvgRenderer *renderer = countablesRenderer();
    const int columns = ceil(sqrt(qreal(quantity)));
    const int rows = ceil(quantity / qreal(columns));
    const int columnsInLastRow = quantity % columns == 0 ? columns : quantity % columns;
    const int itemSize = qMin((requestedSize.width() / qMax(3, columns)), (requestedSize.height() / qMax(3, rows)));
    const QSize resultSize(itemSize * columns, itemSize * rows);
    QPixmap result(resultSize);
    result.fill(Qt::transparent);
    QPainter p(&result);
    for (int row = 0; row < rows; row++) {
        for (int column = 0; column < columns; column++) {
            if (columns * row + column >= quantity)
                break;
            const QString itemId = (item + QLatin1String("_%1")).arg((qrand() % 8 + 1), 2, 10, QLatin1Char('0'));
            const QRect itemRect(column * itemSize + (row == rows-1 ? (columns - columnsInLastRow) * itemSize / 2 : 0),
                                 row * itemSize, itemSize, itemSize);
            renderer->render(&p, itemId, itemRect);
        }
    }
    if (size)
        *size = resultSize;
    return result;
}

inline static QPixmap renderedSvgElement(const QString &elementId, QSvgRenderer *renderer, Qt::AspectRatioMode aspectRatioMode,
                                         QSize *size, const QSize &requestedSize)
{
    const QString rectId = elementId + QLatin1String("_rect");
    const QRectF rect = renderer->boundsOnElement(renderer->elementExists(rectId) ? rectId : elementId);
    if (rect.width() < 1 || rect.height() < 1) {
        qDebug() << "****************** SVG bounding rect is NULL!" << rect << elementId;
        return QPixmap();
    }
    QSize pixmapSize = rect.size().toSize();
    pixmapSize.scale(requestedSize, aspectRatioMode);
    if (pixmapSize.width() < 1 || pixmapSize.height() < 1) {
        qDebug() << "****************** pixmapSize is NULL!" << pixmapSize << requestedSize << elementId;
        return QPixmap();
    }
    QPixmap pixmap(pixmapSize);
    if (pixmap.isNull())
        qDebug() << "****************** pixmap is NULL!" << elementId;
    pixmap.fill(Qt::transparent);
    QPainter p(&pixmap);
    renderer->render(&p, elementId, QRect(QPoint(), pixmapSize));
    if (size)
        *size = pixmapSize;
    return pixmap;
}

inline static QPixmap renderedDesignElement(const ElementVariationList *elements, int variant, QSize *size, const QSize &requestedSize)
{
    const qreal requestedRatio = requestedSize.width() / qreal(requestedSize.height());
    const ElementVariations *elementWithNearestRatio = &elements->last();
    foreach (const ElementVariations &element, *elements) {
        if (qAbs(requestedRatio - element.widthToHeightRatio)
                < qAbs(requestedRatio - elementWithNearestRatio->widthToHeightRatio)) {
            elementWithNearestRatio = &element;
        } else if (element.widthToHeightRatio > elementWithNearestRatio->widthToHeightRatio) {
            break;
        }
    }
    return renderedSvgElement(elementWithNearestRatio->elementIds.at(variant % elementWithNearestRatio->elementIds.count()),
                              designRenderer(), Qt::IgnoreAspectRatio, size, requestedSize);
}

QPixmap ImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    const QStringList idSegments = id.split(QLatin1Char('/'));
    if (requestedSize.width() < 1 && requestedSize.height() < 1) {
        qDebug() << "****************** requestedSize is NULL!" << requestedSize << id;
        return QPixmap();
    }
    if (idSegments.count() < 2) {
        qDebug() << "Not enough parameters for the image provider: " << id;
        return QPixmap();
    }
    const QString &elementId = idSegments.at(1);
    if (idSegments.first() == QLatin1String("background")) {
        return renderedSvgElement(elementId, designRenderer(), Qt::KeepAspectRatioByExpanding, size, requestedSize);
    } else if (idSegments.first() == frameString
               || idSegments.first() == QLatin1String("specialbutton")) {
        return renderedSvgElement(elementId, designRenderer(), Qt::IgnoreAspectRatio, size, requestedSize);
    } else if (idSegments.first() == buttonString) {
        return renderedDesignElement(buttonVariations(),idSegments.at(1).toInt(), size, requestedSize);
    } else if (idSegments.first() == QLatin1String("object")) {
        return renderedSvgElement(elementId, objectRenderer(), Qt::KeepAspectRatio, size, requestedSize);
    } else if (idSegments.first() == QLatin1String("quantity")) {
        if (idSegments.count() != 3) {
            qDebug() << "Wrong number of parameters for quantity images:" << id;
            return QPixmap();
        }
        return quantity(idSegments.at(1).toInt(), idSegments.at(2), size, requestedSize);
    }
    return QPixmap();
}
