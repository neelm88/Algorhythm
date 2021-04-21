import socket
import codecs
import numpy as np
import matplotlib.pyplot as plt
import math
import audioop
import wave
from parse_sheet_music import parse_sheet_music
from note_data import get_dbs, get_freq
from tabulate import tabulate
import struct
HOST = '127.0.0.1'
PORT = 2020
CHUNK = 4096 # number of data points to read at a time
RATE = 16000
TEMPO = 75
notes = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
i, j = 1, 0
start = False
sheet_notes, sheet_timesteps = parse_sheet_music('output/03.txt',TEMPO)
detected = [[]]
while True:
    with socket.socket(socket.AF_INET,socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
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
                timestep = (CHUNK/RATE) * i
                if not start:
                    print(f"before {dbs}")
                    if freq >= 8 and dbs >= 40:
                        start = True
                    else:
                        continue
                print(f"after {dbs}")
                if j >=len(sheet_timesteps):
                    break
                if timestep >= sheet_timesteps[j]:
                    j += 1
                    detected.append([])
                if freq >= 8:
                    m = round(((math.log(freq/440)/math.log(2))*12)+69)
                    note = notes[m % 12]
                    octave = int(m/12) - 1
                    str_note = f"{note}{octave}"
                    detected[j].append(note)
                i += 1
            final_data = []
            count = 0
            for i in range(len(sheet_notes)):
                if i >= len(detected):
                    break
                if sheet_notes[i].upper() in detected[i]:
                    exists = "yes"
                    count += 1
                elif i+1 < len(detected) and sheet_notes[i].upper() in detected[i+1]:
                    exists = "yes"
                    count += 1
                elif i-1 >= 0 and sheet_notes[i].upper() in detected[i-1]:
                    exists = "yes"
                    count += 1                   
                else:
                    exists = "no"
                final_data.append([i+1,sheet_notes[i],exists])
            print(detected)
            print(tabulate(final_data,headers=["Note #","Sheet Music Note","Detected?"]))
            acc = (count/len(sheet_notes)) * 100
            print(f"Accuracy score: {acc}")
            b = bytearray(struct.pack("f", float(acc)))
            print(len(b)) 
            conn.sendall(b)


