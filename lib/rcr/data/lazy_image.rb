module RCR
	module Data
		class LazyImage
			include Logging

			def initialize(content)
				@content = content
			end

			private
			def bruteforce_to_image
				log "Converting imagelike of size #{width}x#{height} to image"
				image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
				(0...width).map { |x|
					(0...height).map { |y|
						image[x, y] = ChunkyPNG::Color.rgb(*self[x, y])
					}
				}
				log "Converted image filled."
				Image.new(image)
			end

			public
			def convert_to_image
				unless @content.is_a?(Image)
					@content =
						if @content.respond_to?(:to_image)
							@content.to_image
						else
							bruteforce_to_image
						end
				end
			end

			Image.instance_methods(false).each do |method|
				define_method(method) do |*args|
					convert_to_image unless @content.respond_to?(method) || @content.is_a?(Image)
					@content.send(method, *args)
				end
			end
		end
	end
end
