require 'gtk2'
require 'rcr/logging'
require 'rcr/data/pixmap_imagelike'

module RCR
	module GUI
		class LetterDrawingArea < Gtk::DrawingArea
			include Logging

			protected
			attr_reader :pixmap

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
				@pixmap = nil

				signal_connect :expose_event do
					expose_event
				end

				signal_connect :configure_event do
					clear if !@pixmap
				end

				# Button 1 = left button (ink)
				# Button 3 = clear
				signal_connect :motion_notify_event do |widget, event|
					x, y, state = event.x, event.y, event.state

					if state.button1_mask? && @pixmap
						draw_with_gc(x, y, style.black_gc)
					end
				end

				signal_connect :button_press_event do |widget, event|
					if @pixmap
						case event.button
						when 1
							# Left button
							draw_with_gc(event.x, event.y, style.black_gc)
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
				Data::PixmapImagelike.new(@pixmap)
			end

			def drawn_letter_variants
				if empty?
					log "Empty, no drawn letter variants."
					nil
				else
					log "Classifying. (pixmap size: #{@pixmap.size.inspect})..."
					@classifier.classify_with_alternatives(drawn_imagelike)
				end
			end

			def drawn_letter
				if empty?
					log "Empty, no drawn letter."
					nil
				else
					log "Classifying. (pixmap size: #{@pixmap.size.inspect})..."
					@classifier.classify(drawn_imagelike)
				end
			end

			def queue_redraw_all
				queue_draw_area(0, 0, *@pixmap.size)
			end

			def clear
				width, height = allocation.width, allocation.height
				@pixmap_width, @pixmap_height = width, height
				log "clearing letter drawing area: width #{width}, height #{height}"

				@pixmap = Gdk::Pixmap.new(window, width, height, -1)
				@pixmap.draw_rectangle(style.white_gc, true, 0, 0, width, height)

				@empty = true

				# Redraw all: show empty state
				queue_redraw_all
			end

			def brush_size
				[allocation.width, allocation.height].min.to_f / 12.0
			end

			def draw_with_gc(x, y, gc)
				width, height = allocation.width, allocation.height
				unless x >= 0 && y >= 0 && x < width && y < height
					log "Brush outside bounds (#{x}x#{y} outside #{width}x#{height})."
					return
				end
				b = brush_size / 2
				rect = [x-b, y-b, b*2, b*2]
				@pixmap.draw_rectangle(gc, true, *rect)

				if empty?
					# Redraw all: show empty state
					queue_redraw_all
					@empty = false
				else
					queue_draw_area(*rect)
				end
			end

			def expose_event
				w, h = allocation.width, allocation.height

				if !@pixmap || [w, h] != [@pixmap_width, @pixmap_height]
					log "letter drawing area size changed, clearing"
					clear
				end

				if empty?
					# Draw empty state
					window.draw_rectangle(style.black_gc, true, 0, 0, w, h)
				else
					# Draw nonempty state
					window.draw_rectangle(style.white_gc, true, 0, 0, w, h)
					window.draw_drawable(style.fg_gc(Gtk::STATE_NORMAL), @pixmap, 0, 0, 0, 0, w, h)
				end
				window.draw_rectangle(style.black_gc, false, 0, 0, w, h)


				# TODO: dalsi veci nad tim
				@overlays.each do |overlay|
					overlay.draw_on_area(self)
				end
			end

			attr_accessor :overlays
		end
	end
end
