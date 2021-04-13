import pyaudio
import numpy as np
import matplotlib.pyplot as plt
import math
import audioop
import wave
from parse_sheet_music import parse_sheet_music
from note_data import get_dbs, get_freq
from tabulate import tabulate
np.set_printoptions(suppress=True)

wf = wave.open('03.wav','rb')
RATE = wf.getframerate()
CHUNK = 4096 # number of data points to read at a time
TEMPO = 75
notes = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]

p=pyaudio.PyAudio() # start the PyAudio class

stream=p.open(format=p.get_format_from_width(wf.getsampwidth()),channels=wf.getnchannels(),rate=RATE,input=True,
              frames_per_buffer=CHUNK) #uses default input device

i, j = 1, 0
sheet_notes, sheet_timesteps = parse_sheet_music('03.txt',TEMPO)
str_data = wf.readframes(CHUNK)
detected = [[]]

while len(str_data) >= CHUNK * 4 and j < len(sheet_timesteps):
    data = np.frombuffer(str_data,dtype=np.int16)
    freq = get_freq(data,CHUNK,RATE)
    dbs = get_dbs(data)
    timestep = (CHUNK/RATE) * i
    if timestep >= sheet_timesteps[j]:
        j += 1
        detected.append([])
    if freq >= 8 and dbs >= 30:
        m = round(((math.log(freq/440)/math.log(2))*12)+69)
        note = notes[m % 12]
        octave = int(m/12) - 1
        str_note = f"{note}{octave}"
        detected[j].append(note)
    i += 1 
    str_data = wf.readframes(CHUNK)

final_data = []
count = 0
for i in range(len(sheet_notes)):
    if sheet_notes[i].upper() in detected[i]:
        exists = "yes"
        count += 1
    else:
        exists = "no"
    final_data.append([i+1,sheet_notes[i],exists])
print(tabulate(final_data,headers=["Note #","Sheet Music Note","Detected?"]))
print(f"Accuracy score: {count/len(sheet_notes)}")