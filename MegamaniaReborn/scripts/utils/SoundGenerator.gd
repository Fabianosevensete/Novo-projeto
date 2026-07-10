extends Node

static func generate_shoot() -> AudioStreamWAV:
	var duration = 0.08
	var freq = 880.0
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t = float(i) / sample_rate
		var envelope = 1.0 - (float(i) / frames)
		var value = sin(t * freq * TAU) * envelope * 0.3
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav


static func generate_explosion() -> AudioStreamWAV:
	var duration = 0.3
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t = float(i) / sample_rate
		var envelope = exp(-t * 10.0)
		var noise = randf_range(-1.0, 1.0)
		var low = sin(t * 80.0 * TAU) * 0.3
		var value = (noise * 0.7 + low * 0.3) * envelope * 0.4
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav


static func generate_hit() -> AudioStreamWAV:
	var duration = 0.05
	var freq = 200.0
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var envelope = 1.0 - (float(i) / frames)
		var value = sin(float(i) / sample_rate * freq * TAU) * envelope * 0.3
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav


static func generate_pickup() -> AudioStreamWAV:
	var duration = 0.2
	var freq_start = 400.0
	var freq_end = 1200.0
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t = float(i) / sample_rate
		var progress = float(i) / frames
		var freq = freq_start + (freq_end - freq_start) * progress
		var envelope = 1.0 - progress * 0.5
		var value = sin(t * freq * TAU) * envelope * 0.25
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav


static func generate_dash() -> AudioStreamWAV:
	var duration = 0.12
	var freq_start = 200.0
	var freq_end = 600.0
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t = float(i) / sample_rate
		var progress = float(i) / frames
		var freq = freq_start + (freq_end - freq_start) * (1.0 - progress)
		var envelope = 1.0 - progress
		var value = sin(t * freq * TAU) * envelope * 0.2
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav


static func generate_boss_warning() -> AudioStreamWAV:
	var duration = 0.6
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t = float(i) / sample_rate
		var envelope = 1.0 - float(i) / frames * 0.5
		var saw = (t * 60.0) - floor(t * 60.0)
		var value = (saw * 2.0 - 1.0) * envelope * 0.2
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav


static func generate_boss_explosion() -> AudioStreamWAV:
	var duration = 0.8
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t = float(i) / sample_rate
		var envelope = exp(-t * 4.0)
		var noise = randf_range(-1.0, 1.0)
		var low = sin(t * 60.0 * TAU) * 0.5
		var mid = sin(t * 120.0 * TAU) * 0.3
		var value = (noise * 0.5 + low + mid) * envelope * 0.3
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav


static func generate_weapon_switch() -> AudioStreamWAV:
	var duration = 0.04
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var envelope = 1.0 - float(i) / frames
		var value = sin(float(i) / sample_rate * 1200.0 * TAU) * envelope * 0.2
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav


static func generate_wave_start() -> AudioStreamWAV:
	var duration = 0.35
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t = float(i) / sample_rate
		var progress = float(i) / frames
		var freq = 300.0 + progress * 600.0
		var envelope = 1.0 - progress * 0.3
		var value = sin(t * freq * TAU) * envelope * 0.2
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav


static func generate_powerup_activate() -> AudioStreamWAV:
	var duration = 0.25
	var sample_rate = 22050
	var frames = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t = float(i) / sample_rate
		var progress = float(i) / frames
		var freq = 500.0 + progress * 400.0
		var envelope = 1.0 - progress * 0.4
		var harmonic = sin(t * freq * TAU) + sin(t * freq * 1.5 * TAU) * 0.5
		var value = harmonic * envelope * 0.15
		var s = int(clamp(value * 32767, -32767, 32767))
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	return wav
