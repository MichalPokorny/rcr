require 'gtk2'
require 'rcr/logging'
require 'rcr/data/cairo_imagelike'

module RCR
	module GUI
		class LetterDrawingArea < Gtk::DrawingArea
			include Logging

			protected
			attr_reader :image

			public
			def empty?
				@empty_state_used && @empty
			end

			def initialize(classifier = nil, options = {}) # Can be used without passed classifier.
				super()

				@empty_state_used = !options[:no_empty_state]
				@empty = true

				@classifier = classifier
				@overlays = []
				@image = nil

				signal_connect :expose_event do
					expose_event
				end

				signal_connect :configure_event do
					clear if !@image
				end

				# Button 1 = left button (ink)
				# Button 3 = clear
				signal_connect :motion_notify_event do |widget, event|
					x, y, state = event.x, event.y, event.state

					if state.button1_mask? && @image
						draw_brush(x, y)
					end
				end

				signal_connect :button_press_event do |widget, event|
					if @image
						case event.button
						when 1
							# Left button
							draw_brush(event.x, event.y)
						when 3
							# Right button
							clear
						else
							log "Unimplemented mouse button pressed: #{event.button}"
						end
					end
				end

				self.events = Gdk::Event::EXPOSURE_MASK |
					Gdk::Event::LEAVE_NOTIFY_MASK |
					Gdk::Event::BUTTON_PRESS_MASK |
					Gdk::Event::POINTER_MOTION_MASK |
					Gdk::Event::POINTER_MOTION_HINT_MASK
			end

			def drawn_imagelike
				Data::CairoImagelike.new(@image)
			end

			def drawn_letter_variants
				if empty?
					log "Empty, no drawn letter variants."
					nil
				else
					log "Classifying. (pixmap size: #{@image.width}x#{@image.height})..."
					@classifier.classify_with_alternatives(drawn_imagelike)
				end
			end

			def drawn_letter
				if empty?
					log "Empty, no drawn letter."
					nil
				else
					log "Classifying. (pixmap size: #{@image.width}x#{@image.height})..."
					@classifier.classify(drawn_imagelike)
				end
			end

			def queue_redraw_all
				queue_draw_area(0, 0, @image.width, @image.height)
			end

			def clear
				width, height = allocation.width, allocation.height
				@image_width, @image_height = width, height
				log "clearing letter drawing area: width #{width}, height #{height}"

				@image = Cairo::ImageSurface.new(width, height) # Gdk::Pixmap.new(window, width, height, -1)
				@image_cr = Cairo::Context.new(@image)
				@image_cr.set_source_rgb 1.0, 1.0, 1.0
				@image_cr.paint
				# @pixmap.draw_rectangle(style.white_gc, true, 0, 0, width, height)

				@empty = true

				# Redraw all: show empty state
				queue_redraw_all
			end

			def brush_size
				[allocation.width, allocation.height].min.to_f / 12.0
			end

			def draw_brush(x, y)
				width, height = allocation.width, allocation.height
				unless x >= 0 && y >= 0 && x < width && y < height
					log "Brush outside bounds (#{x}x#{y} outside #{width}x#{height})."
					return
				end
				b = brush_size / 2
				rect = [x-b, y-b, b*2, b*2]

				@image_cr.set_source_rgb 0.0, 0.0, 0.0
				@image_cr.rectangle(*rect)
				@image_cr.fill

				if empty?
					# Redraw all: show empty state
					queue_redraw_all
					@empty = false
				else
					queue_draw_area(*rect)
				end
			end

			def draw_border(ctx)
				w, h = allocation.width, allocation.height

				ctx.set_source_rgb 0.0, 0.0, 0.0
				ctx.rectangle 0, 0, w, h
				ctx.stroke
			end

			def draw_empty(ctx)
				w, h = allocation.width, allocation.height

				ctx.set_source_rgb 0.9, 0.9, 0.9
				ctx.rectangle 0, 0, w, h
				ctx.fill

				# "X" in the middle
				ctx.move_to w * 0.25, h * 0.25
				ctx.line_to w * 0.75, h * 0.75
				ctx.move_to w * 0.75, h * 0.25
				ctx.line_to w * 0.25, h * 0.75
				ctx.set_source_rgb 0.8, 0.8, 0.8
				ctx.stroke
			end

			def draw_content(ctx)
				ctx.set_source(@image, 0, 0)
				ctx.paint
			end

			def expose_event
				w, h = allocation.width, allocation.height

				if !@image || [w, h] != [@image_width, @image_height]
					log "letter drawing area size changed, clearing"
					clear
				end

				ctx = window.create_cairo_context

				if empty?
					# Draw empty state
					draw_empty(ctx)
				else
					draw_content(ctx)
				end

				draw_border(ctx)

				# TODO: dalsi veci nad tim
				@overlays.each do |overlay|
					overlay.draw_on_area(self)
				end
			end

			attr_accessor :overlays
		end
	end
end
