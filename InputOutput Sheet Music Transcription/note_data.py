import audioop
import numpy as np
def get_dbs(data):
    rms = audioop.rms(data,2)
    return 20 * np.log10(rms)

def get_freq(data,chunk,rate):
    try:
        data = data * np.hanning(len(data)) # smooth the FFT by windowing data
        fft = abs(np.fft.fft(data).real)
        fft = fft[:int(len(fft)/2)] # keep only first half
        freq = np.fft.fftfreq(chunk,1.0/rate)
        freq = freq[:int(len(freq)/2)] # keep only first half
        
        ind = np.where(fft==np.max(fft))
        if ind[0] == chunk - 1:
            return 1
        return freq[ind[0][0]]+1
    except:
        return 1