require 'oily_png'
require 'chunky_png/rmagick'
require 'RMagick'
require 'rcr/logging'

module RCR
	module Data
		class Image
			include Logging

			class EmptyImage < StandardError; end

			def self.from_blob(blob)
				self.new(Magick::Image.from_blob(blob).first)
			end

			def self.load(path)
				self.new(case path
					when /\.png$/
						ChunkyPNG::Image.from_file(path)
					else
						Magick::Image::read(path).first
				end)
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

			private
			def image=(new_image)
				@image = case new_image
					when ChunkyPNG::Canvas
						new_image
					when Magick::Image
						ChunkyPNG::RMagick.import(new_image)
					when String
						raise "Use RCR::Image#load to load images by their path."
					else
						raise ArgumentError, "Cannot import image of type #{new_image.class}"
					end
			end

			public
			def initialize(image)
				self.image = image
			end

			def crop(x, y, width, height)
				raise ArgumentError, "negative cropped part size" if width < 0 or height < 0
				img = @image.crop(x, y, width, height) or raise EmptyImage
				self.class.new(img)
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
				raise ArgumentError, "pixel out of range (x=#{x},y=#{y}, width=#{width},height=#{height})" unless x >= 0 && y >= 0 && x < width && y < height
				pixel = @image.get_pixel(x,y) or raise "Pixel empty: #{x}-#{y}"
				ChunkyPNG::Color.to_truecolor_bytes(pixel)
			end

			# Crops the image by columns
			def crop_by_columns(n_columns, cell_height = nil)
				raise ArgumentError if n_columns <= 0
				column_width = width / n_columns
				raise ArgumentError unless width % column_width

				cell_height ||= column_width

				log "Cropping image of size #{width}x#{height} by #{n_columns}, cell height #{cell_height}"

				(0...n_columns).map { |column|
					(0...height).step(cell_height).map { |y_start|
						crop(column * column_width, y_start, column_width, cell_height)
					}
				}
			end

			def to_raw_data
				bytes = [width, height].pack("QQ")
				bytes += @image.to_rgba_stream
				bytes
			end

			def self.from_raw_data(data)
				bytes = data[0...16]
				width, height = bytes.unpack("QQ")
				data = data[16...data.length]
				self.new(ChunkyPNG::Image.from_rgba_stream(width, height, data))
			end

			def scale!(new_width, new_height)
				new_width, new_height = [new_width, new_height].map(&:to_i)
				raise ArgumentError unless new_width.is_a? Fixnum and new_height.is_a? Fixnum

				rmagick_image = ChunkyPNG::RMagick.export(@image)
				rmagick_image.scale!(new_width, new_height)
				self.image = ChunkyPNG::RMagick.import(rmagick_image)
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
				self.image = rmagick_guillotine
			end

			def guillotine
				self.class.new(rmagick_guillotine)
			end

#			private
#			def rmagick_border_to(new_w, new_h)
#				raise ArgumentError, "Image already bigger than #{[new_w,new_h]} (#{[width,height]})" if new_w < width || new_h < height
#
#				border_x = (width - new_w) / 2
#				border_y = (height - new_h) / 2
#
#				img = ChunkyPNG::RMagick.export(@image)
#
#				img.border!(border_x, border_y, '#FFFFFF')
#				if img.width != new_w || img.height != new_h
#					puts "Warning: bordered to #{[new_w,new_h]}, but got #{[img.width,img.height]}, resizing."
#					img.resize!(new_w, new_h)
#				end
#
#				ChunkyPNG::RMagick.import(img)
#			end
#			
#			public
#			def border_to!(new_w, new_h)
#				@image = rmagick_border_to(new_w, new_h)
#			end
#
#			private
#			def rmagick_resize_to_fit(new_w, new_h)
#				img = ChunkyPNG::RMagick.export(@image)
#				img.resize_to_fit!(new_w, new_h)
#				ChunkyPNG::RMagick.import(img)
#			end
#
#			public
#			def resize_to_fit!(new_w, new_h)
#				@image = rmagick_resize_to_fit(new_w, new_h)
#			end
			def rmagick_border_to_and_resize_to_fit(new_w, new_h)
				img = ChunkyPNG::RMagick.export(@image)
				# puts "#{img.columns}x#{img.rows}"
				img.resize_to_fit!(new_w, new_h)
				# puts "=> #{img.columns}x#{img.rows}"

				#raise "Image already bigger than #{[new_w,new_h]} (#{[img.width,img.height]})" if new_w < img.width || new_h < img.height

				border_x = (new_w - img.columns) / 2
				border_y = (new_h - img.rows) / 2

				raise if border_x < 0 or border_y < 0

				# puts "border: #{border_x}x#{border_y}"

				# ImageMagick zrejme neimplementuje #width a #height. WTF?!

				img.border!(border_x, border_y, '#FFFFFF')
				if img.columns != new_w || img.rows != new_h
					# puts "Warning: bordered to #{[new_w,new_h]}, but got #{[img.columns,img.rows]}, resizing."
					img.resize!(new_w, new_h)
				end

				ChunkyPNG::RMagick.import(img)
			end

			public
			def border_to_and_resize_to_fit!(new_w, new_h)
				self.image = rmagick_border_to_and_resize_to_fit(new_w, new_h)
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

			class PixelEnumerator
				def initialize(image)
					@image = image
				end

				def each
					(0...@image.width).each do |x|
						(0...@image.height).each do |y|
							yield(@image[x, y])
						end
					end
				end

				include Enumerable
			end

			# Yields every pixel as R-G-B triple (0..255)
			def pixels
				PixelEnumerator.new(self)
			end
		end
	end
end
