import numpy as np
def parse_sheet_music(file,tempo):

    with open(file) as f:
        contents = f.read()
        contents = contents.strip('[ ').strip(' ]').split(' ')
        notes = np.empty(len(contents),dtype=np.str0)
        end_timestamp = np.zeros(len(contents))
        for i in range(len(contents)):
            note = contents[i]
            notes[i] = note[0]
            if i == 0:
                end_timestamp[i] = (240/tempo)/int(note[-1])
            else:
                end_timestamp[i] = end_timestamp[i-1] + (240/tempo)/int(note[-1])
    return notes,end_timestamp            
