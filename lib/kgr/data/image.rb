require 'oily_png'
require 'chunky_png/rmagick'
require 'RMagick'

module KGR
	module Data
		class Image
			def self.load(path)
				self.new(ChunkyPNG::Image.from_file(path))
			end

			# pixels: 2D array of R-G-B pixels (0..256)
			def self.from_pixel_block(pixels)
				image = ChunkyPNG::Image.new(pixels.size, pixels.first.size, ChunkyPNG::Color::TRANSPARENT)
				pixels.each_with_index { |row, x|
					row.each_with_index { |pixel, y|
						image[x, y] = ChunkyPNG::Color.rgb(*pixel)
					}
				}
				self.new(image)
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
				#raise unless @image.respond_to?(:resample_bilinear!)

				rmagick_image = ChunkyPNG::RMagick.export(@image)
				thumb = rmagick_image.scale(new_width, new_height)
				@image = ChunkyPNG::RMagick.import(thumb)

				#puts "Width: #{width.inspect}, height: #{height.inspect}"

				#puts "New width: #{new_width.inspect}, new height: #{new_height.inspect}"

				#@image.resample_bilinear!(new_width, new_height)
			end

			def scale(width, height)
				self.class.new(@image.resample_bilinear(width, height))
			end

			private
			def rmagick_guillotine
				rmagick_image = ChunkyPNG::RMagick.export(@image)

				box = rmagick_image.bounding_box
				unless box.width == 0 or box.height == 0
					rmagick_image.crop! box.x, box.y, box.width, box.height
				else
					puts "Warning: empty image"
				end

				ChunkyPNG::RMagick.import(rmagick_image)
			end

			public
			def guillotine!
				@image = rmagick_guillotine
			end

			def guillotine
				self.class.new(rmagick_guillotine)
			end

			private
			def rmagick_mutate
				rmagick_image = ChunkyPNG::RMagick.export(@image)
				# scaling x, rotation x, y, scaling y, translate x, y
				sx = 0.9 + (rand() * 0.2)
				sy = 0.9 + (rand() * 0.2)
				
				max_rot = Math::PI / 8

				rx = (max_rot / 2) - rand() * max_rot
				ry = (max_rot / 2) - rand() * max_rot

				tx, ty = 0, 0

				matrix = Magick::AffineMatrix.new(sx, rx, ry, sy, tx, ty)

				rmagick_image = rmagick_image.affine_transform(matrix)
				ChunkyPNG::RMagick.import(rmagick_image)
			end

			public
			# Applies a slight affine transform
			def mutate
				self.class.new(rmagick_mutate)
			end

			RED = ChunkyPNG::Color.rgb(255, 0, 0)
			GREEN = ChunkyPNG::Color.rgb(0, 255, 0)
			BLUE = ChunkyPNG::Color.rgb(0, 0, 255)

			def draw_rectangle!(x0, y0, x1, y1, stroke = ChunkyPNG::Color.rgb(0, 0, 0), fill = ChunkyPNG::Color::TRANSPARENT)
				# puts "Drawing rect #{x0};#{y0} --- #{x1};#{y1}"
				@image.rect(x0, y0, x1, y1, stroke, fill)
			end
		end
	end
end
