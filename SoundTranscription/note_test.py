import pyaudio
import numpy as np
import matplotlib.pyplot as plt
import math
import audioop

notes = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
np.set_printoptions(suppress=True)

CHUNK = 4096 # number of data points to read at a time
RATE = 44100 # time resolution of the recording device (Hz)

def get_freq(data):
    data = data * np.hanning(len(data)) # smooth the FFT by windowing data
    fft = abs(np.fft.fft(data).real)
    fft = fft[:int(len(fft)/2)] # keep only first half
    freq = np.fft.fftfreq(CHUNK,1.0/RATE)
    freq = freq[:int(len(freq)/2)] # keep only first half
    return freq[np.where(fft==np.max(fft))[0][0]]+1

def get_dbs(data):
    rms = audioop.rms(data,2)
    return 20 * np.log10(rms)

p=pyaudio.PyAudio() # start the PyAudio class
stream=p.open(format=pyaudio.paInt16,channels=1,rate=RATE,input=True,
              frames_per_buffer=CHUNK) #uses default input device

last_note = ""
# create a numpy array holding a single read of audio data
for i in range(1000):
    s = stream.read(CHUNK)
    data = np.frombuffer(s,dtype=np.int16)
    print(s)
    break
    freq = get_freq(data)
    dbs = get_dbs(data)
    if freq >= 8 and dbs >= 35:
        
        m = round(((math.log(freq/440)/math.log(2))*12)+69)
        note = notes[m % 12]
        octave = int(m/12) - 1
        str_note = f"{note}{octave}"
        if last_note !=note:
            print(f"Volume: {dbs} dB")
            print(f"Frequency: {freq} Hz")
            print(f"Note: {str_note} ")
        last_note =note



    #plt.plot(freq,fft)
    #plt.axis([0,4000,None,None])
    #plt.show()
    #plt.close()

stream.stop_stream()
stream.close()
p.terminate()