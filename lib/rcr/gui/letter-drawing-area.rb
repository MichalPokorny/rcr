require 'gtk2'
require 'rcr/logging'

module RCR
	module GUI
		class LetterDrawingArea < Gtk::DrawingArea
			include Logging

			protected
			attr_reader :pixmap

			public
			def initialize
				signal_connect :expose_event do
					expose_event
				end

				signal_connect :configure_event do
					clear if !@pixmap
				end

				signal_connect :motion_nofify_event do |widget, event|
					x, y, state = event.x, event.y, event.state
					if event.hint?
						_, x, y, state = event.window.pointer
					end

					if state.button1_mask? && @pixmap
						draw_brush(x, y)
					end
				end

				signal_connect :button_press_event do |widget, event|
					if event.button == 1 && @pixmap
						draw_brush(event.x, event.y)
					end
				end

				events = Gdk::Event::EXPOSURE_MASK |
					Gdk::Event::LEAVE_NOTIFY_MASK |
					Gdk::Event::BUTTON_PRESS_MASK |
					Gdk::Event::POINTER_MOTION_MASK |
					Gdk::Event::POINTER_MOTION_HINT_MASK
			end

			def clear
				width, height = allocation.width, allocation.height
				log "clearing letter drawing area: width #{width}, height #{height}"

				@pixmap = Gdk::Pixmap.new(window, width, height, -1)
				@pixmap.draw_rectangle(style.white_gc, true, 0, 0, width, height)

				queue_draw_area(0, 0, *@pixmap.size)
			end

			def brush_size
				[allocation.width, allocation.height].min.to_f / 6.0
			end

			def draw_brush(x, y)
				width, height = allocation.width, allocation.height
				unless x >= 0 && y >= 0 && x < width && y < height
					log "Brush outside bounds (#{x}x#{y} outside #{width}x#{height})."
					return
				end

				b = brush_size / 2
				rect = [x-b, y-b, b*2, b*2]
				@pixmap.draw_rectangle(style.black_gc, true, *rect)
				queue_draw_area(*rect)
			end

			def expose_event
				w, h = window_width, window_height

				window.draw_rectangle(style.white_gc, true, 0, 0, w, h)
				window.draw_drawable(style.fg_gc(Gtk::STATE_NORMAL), @pixmap, 0, 0, 0, 0, w, h)
				window.draw_rectangle(style.black_gc, false, 0, 0, w, h)

				# TODO: dalsi veci nad tim
				# draw_on_area(@area)
			end
		end
	end
end
