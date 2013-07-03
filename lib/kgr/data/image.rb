require 'oily_png'
#require 'rmagick'
require 'chunky_png/rmagick'

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

			def [](x,y)
				ChunkyPNG::Color.to_truecolor_bytes(@image.get_pixel(x,y))
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

			def scale!(new_width, new_height)
				raise unless new_width.is_a? Fixnum and new_height.is_a? Fixnum
				raise unless @image.respond_to?(:resample_bilinear!)

				puts "Width: #{width.inspect}, height: #{height.inspect}"

				puts "New width: #{new_width.inspect}, new height: #{new_height.inspect}"

				@image.resample_bilinear!(new_width, new_height)
			end

			def scale(width, height)
				self.class.new(@image.resample_bilinear(width, height))
			end

			def guillotine!
				rmagick_image = ChunkyPNG::RMagick.export(@image)

				w, h = width, height

				p w, h

				box = rmagick_image.bounding_box
				rmagick_image.crop! box.x, box.y, box.width, box.height

				@image = ChunkyPNG::RMagick.import(rmagick_image)

				p @image

				p w, h
			end
		end
	end
end
