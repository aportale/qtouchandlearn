import QtQuick 2.0
import QtQuick.Particles 2.0

Item {
    function burst(particlesCount)
    {
        particles.burst(particlesCount);
    }

    ParticleSystem {
        id: particleSystem
        running: Qt.application.state === Qt.ApplicationActive
    }
    ImageParticle {
        anchors.fill: parent
        system: particleSystem
        rotationVelocity: 50
        rotationVelocityVariation: 20
        source: "../../data/graphics/particle.png"
        clip: true
    }
    Emitter {
        property real _size: (height < width ? height : width) / 2.0
        property real _sizeVariation: _size * 0.1
        anchors.fill: parent
        id: particles
        system: particleSystem
        lifeSpan: 700
        lifeSpanVariation: 200
        velocity: AngleDirection {
            property real _velocityMagnitude: (height < width ? height : width) / 2.0
            magnitude: _velocityMagnitude;
            angleVariation: 360
        }
        size: _size
        sizeVariation: _sizeVariation
        enabled: false
        emitRate: 50
    }
}
