/****************************************************************************
** Meta object code from reading C++ file 'feedback.h'
**
** Created: Fri Aug 5 14:30:49 2011
**      by: The Qt Meta Object Compiler version 63 (Qt 4.8.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "feedback.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'feedback.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_Feedback[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: signature, parameters, type, tag, flags
      17,   10,    9,    9, 0x05,

 // slots: signature, parameters, type, tag, flags
      41,    9,    9,    9, 0x08,

 // methods: signature, parameters, type, tag, flags
      48,    9,    9,    9, 0x02,
      67,    9,    9,    9, 0x02,
     113,   88,    9,    9, 0x02,
     138,   10,    9,    9, 0x22,

       0        // eod
};

static const char qt_meta_stringdata_Feedback[] = {
    "Feedback\0\0volume\0volumeChanged(QVariant)\0"
    "init()\0playCorrectSound()\0"
    "playIncorrectSound()\0volume,emitChangedSignal\0"
    "setAudioVolume(int,bool)\0setAudioVolume(int)\0"
};

void Feedback::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        Feedback *_t = static_cast<Feedback *>(_o);
        switch (_id) {
        case 0: _t->volumeChanged((*reinterpret_cast< QVariant(*)>(_a[1]))); break;
        case 1: _t->init(); break;
        case 2: _t->playCorrectSound(); break;
        case 3: _t->playIncorrectSound(); break;
        case 4: _t->setAudioVolume((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< bool(*)>(_a[2]))); break;
        case 5: _t->setAudioVolume((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData Feedback::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject Feedback::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Feedback,
      qt_meta_data_Feedback, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &Feedback::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *Feedback::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *Feedback::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_Feedback))
        return static_cast<void*>(const_cast< Feedback*>(this));
    return QObject::qt_metacast(_clname);
}

int Feedback::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    }
    return _id;
}

// SIGNAL 0
void Feedback::volumeChanged(QVariant _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
