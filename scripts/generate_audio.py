#!/usr/bin/env python3
"""
Generates clean, synthesized PCM WAV sound effects for «Παντομίμα»:
- correct.wav: Cheerful two-tone chime (major third / fifth)
- pass.wav: Soft muted click / neutral chime
- tick.wav: Crisp countdown tick click
- buzzer.wav: Round-over buzzer buzz
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 44100

def create_wav(filepath, duration_sec, sample_generator):
    num_samples = int(SAMPLE_RATE * duration_sec)
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with wave.open(filepath, "w") as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        
        frames = bytearray()
        for i in range(num_samples):
            t = float(i) / SAMPLE_RATE
            val = sample_generator(t, duration_sec)
            # clamp to -1.0 .. 1.0
            val = max(-1.0, min(1.0, val))
            sample = int(val * 32767.0)
            frames.extend(struct.pack("<h", sample))
        
        wav_file.writeframes(frames)
    print(f"Generated {filepath} ({duration_sec}s)")

def correct_sound(t, dur):
    # Two pleasant notes: C5 (523.25 Hz) then G5 (783.99 Hz)
    envelope = math.exp(-4.0 * t / dur)
    if t < dur * 0.4:
        freq = 587.33  # D5
    else:
        freq = 880.0   # A5
    val = 0.6 * math.sin(2.0 * math.pi * freq * t) + 0.2 * math.sin(4.0 * math.pi * freq * t)
    return val * envelope

def pass_sound(t, dur):
    # Descending neutral tone
    envelope = math.exp(-6.0 * t / dur)
    freq = 440.0 * (1.0 - 0.5 * (t / dur))
    return 0.5 * math.sin(2.0 * math.pi * freq * t) * envelope

def tick_sound(t, dur):
    # Short crisp tick
    envelope = math.exp(-35.0 * t / dur)
    freq = 1200.0
    return 0.4 * math.sin(2.0 * math.pi * freq * t) * envelope

def buzzer_sound(t, dur):
    # Buzzer: 160Hz with rich odd harmonics
    envelope = (1.0 - t / dur) if t < dur else 0
    freq = 180.0
    sig = (
        0.5 * math.sin(2.0 * math.pi * freq * t) +
        0.3 * math.sin(2.0 * math.pi * 3 * freq * t) +
        0.2 * math.sin(2.0 * math.pi * 5 * freq * t)
    )
    return sig * envelope * 0.7

def main():
    audio_dir = os.path.join("assets", "audio")
    create_wav(os.path.join(audio_dir, "correct.wav"), 0.35, correct_sound)
    create_wav(os.path.join(audio_dir, "pass.wav"), 0.25, pass_sound)
    create_wav(os.path.join(audio_dir, "tick.wav"), 0.08, tick_sound)
    create_wav(os.path.join(audio_dir, "buzzer.wav"), 0.60, buzzer_sound)

if __name__ == "__main__":
    main()
