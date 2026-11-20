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

#include "color.h"

#include <cmath>

HslaColor::HslaColor(QObject *parent)
    : QObject(parent)
{
}

qreal HslaColor::hue() const
{
    return m_hue;
}

void HslaColor::setHue(qreal hue)
{
    setComponent(m_hue, hue - std::floor(hue));
}

qreal HslaColor::saturation() const
{
    return m_saturation;
}

void HslaColor::setSaturation(qreal saturation)
{
    setComponent(m_saturation, saturation);
}

qreal HslaColor::lightness() const
{
    return m_lightness;
}

void HslaColor::setLightness(qreal lightness)
{
    setComponent(m_lightness, lightness);
}

qreal HslaColor::alpha() const
{
    return m_alpha;
}

void HslaColor::setAlpha(qreal alpha)
{
    setComponent(m_alpha, alpha);
}

QColor HslaColor::color() const
{
    return QColor::fromHslF(m_hue, m_saturation, m_lightness, m_alpha);
}

void HslaColor::setComponent(qreal &component, qreal value)
{
    value = qBound(0.0, value, 1.0);
    if (qFuzzyCompare(component, value))
        return;
    component = value;
    emit colorChanged();
}
