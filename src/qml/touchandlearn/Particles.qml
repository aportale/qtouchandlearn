import QtQuick 2.0
import QtQuick.Particles 2.0

Item {
    function burst(particlesCount)
    {
        particleSystem.running = true
        particles.burst(particlesCount);
        particleRunningTimer.start();
    }

    Timer {
        id: particleRunningTimer
        interval: particles.lifeSpan + particles.lifeSpanVariation + 50
        onTriggered: particleSystem.running = false;
    }

    ParticleSystem {
        id: particleSystem
        running: true
        Timer {
            // The first instance of ParticleSystem will take a while to initialize
            // It does only nitialize while it is "running"
            interval: 0
            onTriggered: parent.running = false;
        }
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
