require 'wavefile'
require 'chunky_png'

path = ARGV[0] or raise "Specify stereo .wav as first param"

info = WaveFile::Reader.info(path)
puts "Duration: #{info.sample_frame_count / info.sample_rate}"
samples = []
num_buffers = 0
WaveFile::Reader.new(path).each_buffer(4096) do |buffer|
  if info.channels == 1
    samples += buffer.samples
  elsif info.channels == 2
    samples += buffer.samples.map { |sample| (sample[0] + sample[1]) / 2 }
  else
    raise "Unexpected number of channels: #{info.channel}"
  end
  num_buffers += 1
  p (num_buffers * 4096 / info.sample_rate) if num_buffers % 100 == 0
end

STEP_SIZE = 100
samples += [0] * 4000

def get_maxes samples, window_size, step_size
  maxes = []
  ((samples.size - window_size) / step_size).times do |i|
    p (i * step_size / 44100) if i % 1000 == 0
    window = samples[(i * step_size)...((i * step_size) + window_size)]
    window.sort!
    maxes.push window[window_size * 9 / 10] - window[window_size * 1 / 10]
  end
  maxes
end

#hann = []
#WINDOW_SIZE.times do |i|
#  hann.push 0.5 * (1 - Math.cos(2 * Math::PI * i / WINDOW_SIZE))
#end

puts 'Taking maxes with window 4000...'
maxes = get_maxes samples, 4000, STEP_SIZE
puts 'Taking maxes with window 400...'
maxes2 = get_maxes samples, 400, STEP_SIZE

cuts = []
cuts2 = []
#png = ChunkyPNG::Image.new (samples.size / STEP_SIZE), 250, ChunkyPNG::Color::WHITE
(samples.size / STEP_SIZE).times do |x|
  max = maxes[x] || 0
  y = 149 - (max / 400)
#  png[x,y] = ChunkyPNG::Color::BLACK

  max2 = maxes2[x] || 0
  y = 149 - (max2 / 400)
#  png[x,y] = ChunkyPNG::Color::rgb(255, 0, 0)

  if max2 > 0
    ratio = max.to_f / max2
    if ratio > 1.8
      cuts2.push [x, ratio]
      if cuts.last && (x - cuts.last[1]) < 30
        cuts.last[1] = x
        cuts.last[2].push x
        cuts.last[3].push ratio
      else
        cuts.push [x, x, [x], [ratio]]
      end
    end
  end
end

if false
cuts.each do |cut|
  x0, x1, xs, ratios = cut
  max_ratio = 0
  best_x = 0
  ratios.each_with_index do |ratio, i|
    if ratio > max_ratio
      max_ratio = ratio
      best_x = xs[i]
    end
  end
  #x = xs.reduce { |x, y| x + y } / xs.size
  x = best_x
  #200.times do |y|
  #  png[x,y] = ChunkyPNG::Color::rgb(255, 0, 0)
  #end
end
end

x_cuts = []
cuts2.sort_by { |cut2| -cut2[1] }.each do |cut2|
  x, ratio = cut2
  if x_cuts.count { |x_cut| (x - x_cut).abs < 100 } == 0
#    200.times do |y|
#      png[x,y] = ChunkyPNG::Color::rgb(255, 0, 0)
#    end
    x_cuts.push x
  end
end
x_cuts.sort!

#png.save 'filename.png'

format = WaveFile::Format.new(:mono, :pcm_16, 44100)
x_cuts.each_with_index do |x, i|
  filename = sprintf('%02d.wav', i)
  WaveFile::Writer.new(filename, format) do |writer|
    next_x = (i < x_cuts.size - 1 ? x_cuts[i + 1] : samples.size / STEP_SIZE)
    p [filename, x, next_x]
    buffer = WaveFile::Buffer.new(samples[(x * STEP_SIZE)...(next_x * STEP_SIZE)], format)
    writer.write buffer
  end
end

