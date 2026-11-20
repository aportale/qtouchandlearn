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

#pragma once

#include <QtCore/QObject>
#include <QtGui/QColor>
#include <QtQml/QQmlEngine>

// A color from its hue, saturation, lightness and alpha, each from 0 to 1, like Qt.hsla(). The
// hue wraps around, so that 1.25 is the same as 0.25.
// Qt.hsla() and Qt.rgba() return a QVariant, which qmlcachegen cannot convert to a QColor. A
// function of a singleton that returns a QColor does not compile either, not even one of the
// Color singleton of Qt Quick 6.12. The color property of an HslaColor compiles, when the
// binding refers to the HslaColor by its id.
class HslaColor : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(qreal hue READ hue WRITE setHue NOTIFY colorChanged FINAL)
    Q_PROPERTY(qreal saturation READ saturation WRITE setSaturation NOTIFY colorChanged FINAL)
    Q_PROPERTY(qreal lightness READ lightness WRITE setLightness NOTIFY colorChanged FINAL)
    Q_PROPERTY(qreal alpha READ alpha WRITE setAlpha NOTIFY colorChanged FINAL)
    Q_PROPERTY(QColor color READ color NOTIFY colorChanged FINAL)

public:
    explicit HslaColor(QObject *parent = nullptr);

    qreal hue() const;
    void setHue(qreal hue);
    qreal saturation() const;
    void setSaturation(qreal saturation);
    qreal lightness() const;
    void setLightness(qreal lightness);
    qreal alpha() const;
    void setAlpha(qreal alpha);
    QColor color() const;

signals:
    void colorChanged();

private:
    void setComponent(qreal &component, qreal value);

    qreal m_hue = 0;
    qreal m_saturation = 0;
    qreal m_lightness = 0;
    qreal m_alpha = 1;
};
