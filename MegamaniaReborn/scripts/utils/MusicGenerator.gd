extends Node

const SAMPLE_RATE = 22050
const BPM = 140.0
const BEAT_DURATION = 60.0 / BPM

static func generate_battle_music(duration: float = 16.0) -> AudioStreamWAV:
	var total_frames = int(duration * SAMPLE_RATE)
	var beats = int(duration / BEAT_DURATION)
	var data = PackedByteArray()
	data.resize(total_frames * 2)
	var melody_notes = [262, 294, 330, 349, 392, 349, 330, 294, 
						262, 294, 330, 349, 392, 440, 392, 349]
	var bass_notes = [131, 131, 165, 165, 175, 175, 131, 131,
					  131, 131, 165, 165, 196, 196, 165, 165]
	var chord_prog = [
		[262, 330, 392],
		[262, 330, 392],
		[294, 349, 440],
		[294, 349, 440],
		[330, 392, 494],
		[330, 392, 494],
		[262, 330, 392],
		[262, 330, 392]
	]
	for i in range(total_frames):
		var t = float(i) / SAMPLE_RATE
		var beat_index = int(t / BEAT_DURATION) % beats
		var beat_phase = (t / BEAT_DURATION) - int(t / BEAT_DURATION)
		var sample: float = 0.0
		var melody_note = melody_notes[beat_index % melody_notes.size()]
		var melody_freq = float(melody_note)
		var melody = sin(t * melody_freq * TAU) * 0.08
		var melody_envelope = 1.0 - beat_phase * 0.7
		melody *= melody_envelope if beat_phase < 0.5 else 0.0
		sample += melody
		var bass_note = bass_notes[beat_index % bass_notes.size()]
		var bass_freq = float(bass_note)
		var bass_amp = 0.0
		if beat_phase < 0.15:
			bass_amp = 1.0 - beat_phase / 0.15
		var bass = sin(t * bass_freq * TAU) * bass_amp * 0.15
		sample += bass
		var chord_idx = beat_index % chord_prog.size()
		for note in chord_prog[chord_idx]:
			var chord_env = 1.0 - beat_phase * 0.3 if beat_phase < 0.75 else 0.0
			sample += sin(t * float(note) * TAU) * chord_env * 0.03
		var kick = 0.0
		if beat_phase < 0.08:
			var kick_env = 1.0 - beat_phase / 0.08
			kick = sin(t * (80.0 - beat_phase * 200.0) * TAU) * kick_env * 0.2
		sample += kick
		var snare = 0.0
		if beat_index % 2 == 1 and beat_phase < 0.05:
			var snare_env = 1.0 - beat_phase / 0.05
			var noise = randf_range(-1.0, 1.0)
			snare = noise * snare_env * 0.12
		sample += snare
		sample = clamp(sample, -1.0, 1.0)
		var s = int(sample * 32767)
		s = clamp(s, -32767, 32767)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_frames
	return wav


static func generate_boss_music(duration: float = 16.0) -> AudioStreamWAV:
	var total_frames = int(duration * SAMPLE_RATE)
	var beats = int(duration / BEAT_DURATION)
	var data = PackedByteArray()
	data.resize(total_frames * 2)
	var melody_notes = [196, 185, 175, 165, 175, 185, 196, 233,
						262, 233, 196, 185, 175, 165, 156, 147]
	var bass_notes = [98, 98, 110, 110, 98, 98, 131, 131]
	for i in range(total_frames):
		var t = float(i) / SAMPLE_RATE
		var beat_index = int(t / BEAT_DURATION) % beats
		var beat_phase = (t / BEAT_DURATION) - int(t / BEAT_DURATION)
		var sample: float = 0.0
		var melody_note = melody_notes[beat_index % melody_notes.size()]
		var melody_freq = float(melody_note)
		var melody = sin(t * melody_freq * TAU) * 0.06
		var melody_env = 1.0 - beat_phase * 0.8
		melody *= melody_env if beat_phase < 0.4 else 0.0
		sample += melody
		sample += sin(t * melody_freq * 0.5 * TAU) * 0.1
		var bass_note = bass_notes[beat_index % bass_notes.size()]
		var bass_freq = float(bass_note)
		var bass_amp = 0.0
		if beat_phase < 0.2:
			bass_amp = 1.0 - beat_phase / 0.2
		var bass = sin(t * bass_freq * TAU) * bass_amp * 0.18
		sample += bass
		var kick = 0.0
		if beat_phase < 0.1:
			var kick_env = 1.0 - beat_phase / 0.1
			kick = sin(t * (70.0 - beat_phase * 300.0) * TAU) * kick_env * 0.25
		sample += kick
		if beat_index % 2 == 1 and beat_phase < 0.06:
			var snare_env = 1.0 - beat_phase / 0.06
			var noise = randf_range(-1.0, 1.0)
			sample += noise * snare_env * 0.15
		if beat_phase < 0.05:
			var hat = randf_range(-0.5, 0.5) * (1.0 - beat_phase / 0.05) * 0.08
			sample += hat
		sample = clamp(sample, -0.9, 0.9)
		var s = int(sample * 32767)
		s = clamp(s, -32767, 32767)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_frames
	return wav
