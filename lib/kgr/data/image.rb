require 'oily_png'

module KGR
	module Data
		class Image
			def self.load(path)
				self.new(ChunkyPNG::Image.from_file(path))
			end

			def initialize(image)
				@image = image
			end

			def crop(x, y, width, height)
				self.class.new(@image.crop(x, y, width, height))
			end

			def save(file)
				@image.save(file)
			end

			def width
				@image.width
			end

			def height
				@image.height
			end

			# Crops the image by columns
			def crop_by_columns(n_columns, cell_height = nil)
				raise ArgumentError if n_columns <= 0
				column_width = width / n_columns
				raise ArgumentError unless width % column_width

				cell_height ||= column_width

				puts "Cropping image of size #{width}x#{height} by #{n_columns}, cell height #{cell_height}"

				(0...n_columns).map { |column|
					(0...height).step(cell_height).map { |y_start|
						crop(column * column_width, y_start, column_width, cell_height)
					}
				}
			end

			def to_raw_data
				bytes = [ width, height ].pack("QQ")
				# print "(#{width}, #{height})"
				# puts " >>> #{bytes.inspect}"

				bytes += @image.to_rgba_stream

				# puts "to_raw_data gave #{bytes.size} B"

				bytes
			end

			def self.from_raw_data(data)
				# puts "from_raw_data got #{data.size} B"
				bytes = data[0...16]
				# print "<<< #{bytes.inspect}"	
				width, height = bytes.unpack("QQ")
				# puts " (#{width}, #{height})"
				data = data[16...data.length]
				self.new(ChunkyPNG::Image.from_rgba_stream(width, height, data))
			end
		end
	end
end
