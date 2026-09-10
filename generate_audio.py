import wave
import struct
import math

def generate_tone(filename, freq, duration, volume=0.5):
    sample_rate = 44100
    n_samples = int(sample_rate * duration)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(n_samples):
            # Triangle wave or sine wave depending on what we want
            # Let's do a square wave for a harsh buzzer, sine for correct/pass
            if 'buzzer' in filename:
                # Square wave for harsh buzzer
                period = sample_rate / freq
                val = 1.0 if (i % period) < (period / 2) else -1.0
                # LFO modulation to make it sound like a buzzer/siren
                val *= (0.8 + 0.2 * math.sin(2 * math.pi * 10 * i / sample_rate))
            elif 'correct' in filename:
                # Quick ascending chime (two sine waves)
                f = freq if i < n_samples/2 else freq * 1.5
                val = math.sin(2 * math.pi * f * i / sample_rate)
                # fade out
                val *= (1.0 - (i / n_samples))
            else: # pass
                # Descending dull chime
                f = freq if i < n_samples/2 else freq * 0.75
                val = math.sin(2 * math.pi * f * i / sample_rate)
                # fade out
                val *= (1.0 - (i / n_samples))
                
            sample = int(val * volume * 32767.0)
            # clamp
            sample = max(-32768, min(32767, sample))
            wav_file.writeframes(struct.pack('h', sample))

# 1. Buzzer (Harsh square wave, ~150Hz, 3 seconds)
generate_tone('assets/audio/buzzer.wav', 150.0, 3.0, 0.8)

# 2. Correct (Ascending chime, 0.5s)
generate_tone('assets/audio/correct.wav', 600.0, 0.5, 0.6)

# 3. Pass (Descending chime, 0.5s)
generate_tone('assets/audio/pass.wav', 400.0, 0.5, 0.6)
