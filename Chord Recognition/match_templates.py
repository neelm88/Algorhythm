"""
Algorithm based on the paper 'Automatic Chord Recognition from
Audio Using Enhanced Pitch Class Profile' by Kyogu Lee
This script computes 12 dimensional chromagram for chord detection
@author ORCHISAMA
"""

from __future__ import division
import numpy as np 
import os
import matplotlib.pyplot as plt
from scipy.io.wavfile import read
import json
from chromagram import compute_chroma


"""Correlate chord with existing binary chord templates to find best batch"""


"""read from JSON file to get chord templates"""
with open('chord_templates.json', 'r') as fp:
	templates_json = json.load(fp)

chords = ['N','G','G#','A','A#','B','C','C#','D','D#','E','F','F#','Gm','G#m','Am','A#m','Bm','Cm','C#m','Dm','D#m','Em','Fm','F#m']
templates = []

for chord in chords:
	if chord == 'N':
		continue
	templates.append(templates_json[chord])


def get_chords(fs,s,chord):
	x = s[::4]
	x = x[:,1]
	fs = int(fs/4)

	#framing audio, window length = 8192, hop size = 1024 and computing PCP
	nfft = 8192
	hop_size = 1024
	nFrames = int(np.round(len(x)/(nfft-hop_size)))
	#zero padding to make signal length long enough to have nFrames
	x = np.append(x, np.zeros(nfft))
	xFrame = np.empty((nfft, nFrames))
	start = 0   
	chroma = np.empty((12,nFrames)) 
	id_chord = np.zeros(nFrames, dtype='int32')
	timestamp = np.zeros(nFrames)
	max_cor = np.zeros(nFrames)
	#print(f'Chord: {chord}')
	#print('Time (s)', 'Chord')

	for n in range(nFrames):
		xFrame[:,n] = x[start:start+nfft] 
		start = start + nfft - hop_size 
		timestamp[n] = n*(nfft-hop_size)/fs
		chroma[:,n] = compute_chroma(xFrame[:,n],fs)
		plt.figure(1)
		plt.plot(chroma[:,n])

		"""Correlate 12D chroma vector with each of 24 major and minor chords"""
		cor_vec = np.zeros(24)
		for ni in range(24):
			cor_vec[ni] = np.correlate(chroma[:,n], np.array(templates[ni])) 
		max_cor[n] = np.max(cor_vec)
		id_chord[n] =  np.argmax(cor_vec) + 1


	#if max_cor[n] < threshold, then no chord is played
	#might need to change threshold value
	id_chord[np.where(max_cor < 0.7*np.max(max_cor))] = 0
	ident_chords = []
	for n in range(nFrames):
		#print(timestamp[n],chords[id_chord[n]])
		ident_chords.append(chords[id_chord[n]])
	return ident_chords

	# #Plotting all figures
	# plt.figure(1)
	# notes = ['G','G#','A','A#','B','C','C#','D','D#','E','F','F#']
	# plt.xticks(np.arange(12),notes)
	# plt.title('Pitch Class Profile')
	# plt.xlabel('Note')
	# plt.grid(True)

	# plt.figure(2)
	# plt.yticks(np.arange(25), chords)
	# plt.plot(timestamp, id_chord)
	# plt.xlabel('Time in seconds')
	# plt.ylabel('Chords')
	# plt.title('Identified chords')
	# plt.grid(True)
	# plt.show()

"""read audio and compute chromagram"""
acc_count = 0
for chord in chords:
	if chord == 'N':
		continue
	directory = os.getcwd() + '/test_chords/'
	if 'm' in chord:
		fname = f'Grand Piano - Fazioli - minor chords - {chord} higher.wav'
	else:
		fname = f'Grand Piano - Fazioli - major {chord} middle.wav'
	(fs,s) = read(directory + fname)
	ident_chords = get_chords(fs,s,chord)
	if chord in ident_chords:
		acc_count += 1
	else:
		print(chord)
		print(ident_chords)
print(f"Accuracy: {acc_count/(len(chords) - 1)}")



