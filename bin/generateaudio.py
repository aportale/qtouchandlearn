#!/usr/bin/env python3
"""
Generates the answer feedback sounds in src/TouchAndLearn/data/audio.

The notes are defined below. Each sound is written as a MIDI file, rendered with the
FluidSynth command line tool and a General MIDI SoundFont, then trimmed, faded out and
normalized. Only the Python standard library is needed.

Requirements:
  - FluidSynth (https://github.com/FluidSynth/fluidsynth/releases), either in PATH or
    passed with --fluidsynth
  - A General MIDI SoundFont, e.g. GeneralUser GS
    (https://github.com/mrbumpy409/GeneralUser-GS), passed with --soundfont

Usage:
  python generateaudio.py --soundfont GeneralUser-GS.sf2 [--output DIR] [SOUND ...]
"""

import argparse
import array
import math
import shutil
import struct
import subprocess
import sys
import tempfile
import wave
from dataclasses import dataclass
from pathlib import Path

# General MIDI program numbers, zero based
VIBRAPHONE = 11
TUBA = 58

SAMPLE_RATE = 44100
PEAK_DBFS = -17.0   # Loudness of the WAVs that were generated with abcmidi + VLC
RELEASE_S = 0.4     # How long the sound keeps ringing after the last note ends
FADE_OUT_S = 0.15   # Fade-out at the end of the release, so that it does not click


@dataclass
class Voice:
    pan: int      # MIDI pan, 0 = left, 64 = center, 127 = right
    notes: list   # (start, duration, pitch) tuples. Start and duration are in eighth notes


@dataclass
class Sound:
    program: int
    bpm: int      # Quarter notes per minute
    voices: list


def correct(*voices):
    return Sound(VIBRAPHONE, 120, list(voices))


def incorrect(bpm, notes):
    return Sound(TUBA, bpm, [Voice(64, notes)])


SOUNDS = {
    "correctanswer_01": correct(
        Voice(20, [(0, 1, "C4"), (1, 1, "G4")]),
        Voice(40, [(0, 1, "E4"), (1, 1, "C4")]),
        Voice(60, [(1.5, 1, "C4"), (2.5, 1, "G4")]),
        Voice(80, [(1.5, 1, "E4"), (2.5, 1, "C5")]),
    ),
    "correctanswer_02": correct(
        Voice(20, [(0, 2, "C4")]),
        Voice(40, [(0.5, 2, "E4")]),
        Voice(60, [(1, 2, "G4")]),
        Voice(80, [(1.5, 2, "C5")]),
    ),
    "correctanswer_03": correct(
        Voice(20, [(0, 2, "C4")]),
        Voice(60, [(0.5, 2, "G4")]),
        Voice(40, [(1, 2, "E4")]),
        Voice(80, [(1.5, 2, "C5")]),
    ),
    "correctanswer_04": correct(
        Voice(20, [(0, 1, "C4"), (1, 1, "E4")]),
        Voice(40, [(0, 1, "E4"), (1, 1, "C5")]),
        Voice(60, [(1.5, 1, "C4"), (2.5, 1, "G4")]),
        Voice(80, [(1.5, 1, "G4"), (2.5, 1, "C5")]),
    ),
    "correctanswer_05": correct(
        Voice(20, [(0, 1, "C4"), (1, 1, "E4")]),
        Voice(40, [(1, 1, "G4")]),
        Voice(60, [(1.5, 1, "C4"), (2.5, 1, "G4")]),
        Voice(80, [(1.5, 1, "E4"), (2.5, 1, "C5")]),
    ),
    "incorrectanswer_01": incorrect(260, [(0, 2, "A3"), (2, 3, "E3")]),
    "incorrectanswer_02": incorrect(200, [(0, 1, "A3"), (1, 1, "F#3"), (2, 2, "D3")]),
    "incorrectanswer_03": incorrect(200, [(0, 1, "A#3"), (1, 1, "G3"), (2, 2, "D#3")]),
    "incorrectanswer_04": incorrect(260, [(0, 2, "F3"), (2, 3, "C#3")]),
}

TICKS_PER_QUARTER = 480
TICKS_PER_EIGHTH = TICKS_PER_QUARTER // 2


def midi_note_number(name):
    semitones = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
    pitch = semitones[name[0]]
    octave = name[1:]
    if octave.startswith("#"):
        pitch += 1
        octave = octave[1:]
    elif octave.startswith("b"):
        pitch -= 1
        octave = octave[1:]
    return 12 * (int(octave) + 1) + pitch  # C4 = 60


def variable_length_quantity(value):
    result = [value & 0x7F]
    value >>= 7
    while value:
        result.insert(0, (value & 0x7F) | 0x80)
        value >>= 7
    return bytes(result)


def last_note_end(sound):
    """In eighth notes"""
    return max(start + duration for voice in sound.voices for start, duration, _ in voice.notes)


def eighths_to_seconds(sound, eighths):
    return eighths * 30 / sound.bpm


def midi_file(sound):
    """Returns a type 0 MIDI file. Each voice gets its own channel, so that it can be panned."""
    events = []  # (tick, order, bytes). At equal ticks, note offs (order 0) come first
    for channel, voice in enumerate(sound.voices):
        events.append((0, 0, bytes([0xC0 | channel, sound.program])))
        events.append((0, 0, bytes([0xB0 | channel, 10, voice.pan])))
        for start, duration, pitch in voice.notes:
            note = midi_note_number(pitch)
            velocity = 105 if start == 0 else 80  # Accent like abc2midi
            on = round(start * TICKS_PER_EIGHTH)
            off = round((start + duration) * TICKS_PER_EIGHTH)
            events.append((on, 1, bytes([0x90 | channel, note, velocity])))
            events.append((off, 0, bytes([0x80 | channel, note, 0])))
    # Keep the file running after the last note, so that FluidSynth renders the release
    end = round((last_note_end(sound) + 4) * TICKS_PER_EIGHTH)

    microseconds_per_quarter = round(60_000_000 / sound.bpm)
    track = bytearray(b"\x00\xFF\x51\x03" + microseconds_per_quarter.to_bytes(3, "big"))
    tick = 0
    for event_tick, _, data in sorted(events, key=lambda e: (e[0], e[1])):
        track += variable_length_quantity(event_tick - tick) + data
        tick = event_tick
    track += variable_length_quantity(end - tick) + b"\xFF\x2F\x00"

    header = b"MThd" + struct.pack(">IHHH", 6, 0, 1, TICKS_PER_QUARTER)
    return header + b"MTrk" + struct.pack(">I", len(track)) + bytes(track)


def read_float_wav(path):
    """Returns (channels, samples) of a 32 bit float WAV file, as written by FluidSynth."""
    data = path.read_bytes()
    if data[:4] != b"RIFF" or data[8:12] != b"WAVE":
        raise ValueError(f"{path} is not a WAV file")
    channels = None
    position = 12
    while position + 8 <= len(data):
        chunk_id = data[position:position + 4]
        chunk_size = struct.unpack("<I", data[position + 4:position + 8])[0]
        chunk = data[position + 8:position + 8 + chunk_size]
        if chunk_id == b"fmt ":
            _, channels, _, _, _, bits = struct.unpack("<HHIIHH", chunk[:16])
            if bits != 32:
                raise ValueError(f"{path} has {bits} bit samples, expected 32 bit float")
        elif chunk_id == b"data":
            samples = array.array("f")
            samples.frombytes(chunk)
            if sys.byteorder == "big":
                samples.byteswap()
            return channels, samples
        position += 8 + chunk_size + (chunk_size & 1)
    raise ValueError(f"{path} has no audio data")


def render(sound, fluidsynth, soundfont, work_dir, name):
    midi_path = work_dir / f"{name}.mid"
    raw_path = work_dir / f"{name}.raw.wav"
    midi_path.write_bytes(midi_file(sound))
    subprocess.run([fluidsynth, "-n", "-i", "-q",
                    "-r", str(SAMPLE_RATE), "-T", "wav", "-O", "float",
                    "-F", str(raw_path), str(soundfont), str(midi_path)],
                   check=True)
    return read_float_wav(raw_path)


def post_process(sound, channels, samples):
    """Trims the sound to the release time, fades it out and normalizes it to 16 bit."""
    frames = round((eighths_to_seconds(sound, last_note_end(sound)) + RELEASE_S) * SAMPLE_RATE)
    samples = samples[:frames * channels]
    frames = len(samples) // channels

    fade_frames = round(FADE_OUT_S * SAMPLE_RATE)
    for frame in range(max(0, frames - fade_frames), frames):
        remaining = (frames - frame) / fade_frames
        factor = 0.5 - 0.5 * math.cos(math.pi * remaining)  # Raised cosine
        for channel in range(channels):
            samples[frame * channels + channel] *= factor

    peak = max(abs(s) for s in samples)
    gain = 10 ** (PEAK_DBFS / 20) / peak
    pcm = array.array("h", (max(-32768, min(32767, round(s * gain * 32767))) for s in samples))
    if sys.byteorder == "big":
        pcm.byteswap()
    return pcm


def write_wav(path, channels, pcm):
    with wave.open(str(path), "wb") as file:
        file.setnchannels(channels)
        file.setsampwidth(2)
        file.setframerate(SAMPLE_RATE)
        file.writeframes(pcm.tobytes())


def main():
    default_output = Path(__file__).resolve().parent.parent / "src" / "TouchAndLearn" / "data" / "audio"
    parser = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    parser.add_argument("--soundfont", type=Path, required=True, help="General MIDI .sf2 file")
    parser.add_argument("--fluidsynth", default="fluidsynth", help="FluidSynth executable")
    parser.add_argument("--output", type=Path, default=default_output, help="Output directory")
    parser.add_argument("--keep-midi", action="store_true", help="Also write the .mid files")
    parser.add_argument("sounds", nargs="*", metavar="SOUND",
                        help=f"Sounds to generate (default: all): {', '.join(SOUNDS)}")
    args = parser.parse_args()

    unknown = [name for name in args.sounds if name not in SOUNDS]
    if unknown:
        parser.error(f"Unknown sounds: {', '.join(unknown)}")
    fluidsynth = shutil.which(args.fluidsynth)
    if not fluidsynth:
        parser.error(f"FluidSynth not found: {args.fluidsynth}")
    if not args.soundfont.is_file():
        parser.error(f"SoundFont not found: {args.soundfont}")
    args.output.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as work_dir:
        for name in args.sounds or SOUNDS:
            sound = SOUNDS[name]
            channels, samples = render(sound, fluidsynth, args.soundfont, Path(work_dir), name)
            write_wav(args.output / f"{name}.wav", channels, post_process(sound, channels, samples))
            if args.keep_midi:
                shutil.copy(Path(work_dir) / f"{name}.mid", args.output)
            print(f"{args.output / name}.wav")


if __name__ == "__main__":
    main()
