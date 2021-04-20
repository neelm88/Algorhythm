import socket
import codecs
import pyaudio
import numpy as np
import matplotlib.pyplot as plt
import math
import audioop
import wave
from parse_sheet_music import parse_sheet_music
from note_data import get_dbs, get_freq
from tabulate import tabulate
HOST = '127.0.0.1'
PORT = 2020
CHUNK = 4096 # number of data points to read at a time
RATE = 12000
TEMPO = 75
notes = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
# sheet_notes, sheet_timesteps = parse_sheet_music('output/03.txt',TEMPO)
detected = [[]]
with socket.socket(socket.AF_INET,socket.SOCK_STREAM) as s:
    s.bind((HOST,PORT))
    s.listen()
    conn, addr = s.accept()
    with conn:
        print('Connected by', addr)
        while True:
            data = conn.recv(CHUNK)
            if not data:
                break
            data = np.frombuffer(data,dtype=np.int16)
            freq = get_freq(data,CHUNK,RATE)
            dbs = get_dbs(data)
            if freq >= 8 and dbs >= 30:
                m = round(((math.log(freq/440)/math.log(2))*12)+69)
                note = notes[m % 12]
                octave = int(m/12) - 1
                str_note = f"{note}{octave}"
                print(f"Volume: {dbs} dB")
                print(f"Frequency: {freq} Hz")
                print(f"Note: {str_note} ")


# final_data = []
# count = 0
# for i in range(len(sheet_notes)):
#     if sheet_notes[i].upper() in detected[i]:
#         exists = "yes"
#         count += 1
#     else:
#         exists = "no"
#     final_data.append([i+1,sheet_notes[i],exists])
# print(tabulate(final_data,headers=["Note #","Sheet Music Note","Detected?"]))
# print(f"Accuracy score: {count/len(sheet_notes)}")