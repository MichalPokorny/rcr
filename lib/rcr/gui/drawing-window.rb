require 'gtk2'
require 'rcr/logging'

module RCR
	module GUI
		class DrawingWindow < Gtk::Window
			include Logging

			protected
			attr_reader :pixmap

			public
			def clear_canvas
				width, height = window_width, window_height

				log "clearing canvas: width #{width} height #{height}"

				@pixmap = Gdk::Pixmap.new(@area.window, width, height, -1)
				@pixmap.draw_rectangle(@area.style.white_gc, true, 0, 0, window_width, window_height)

				@area.queue_draw_area 0, 0, *@pixmap.size
			end

			def window_width
				256
			end

			def window_height
				256
			end

			def canvas_expose_event
				w, h = window_width, window_height

				@area.window.draw_rectangle(@area.style.white_gc, true, 0, 0, w, h)
				@area.window.draw_drawable(@area.style.fg_gc(Gtk::STATE_NORMAL), @pixmap, 0, 0, 0, 0, w, h)
				@area.window.draw_rectangle(@area.style.black_gc, false, 0, 0, w, h)

				draw_on_area(@area)
			end

			def draw_on_area(area)
				# unimplemented
			end

			def brush_size
				8
			end

			def draw_brush(x, y)
				unless x >= 0 && y >= 0 && x < window_width && y < window_height
					log "Brush outside bounds (#{x}x#{y} outside #{window_width}x#{window_height})."
					return
				end

				b = brush_size / 2
				rect = [(x-b).floor, (y-b).floor, b*2, b*2]
				@pixmap.draw_rectangle(@area.style.black_gc, true, *rect)
				@area.queue_draw_area(*rect)
			end

			def add_box_controls(box)
				# Not implemented.
			end

			def title
				"(title not set)"
			end

			def initialize
				super

				set_title title
				signal_connect "destroy" do
					Gtk.main_quit
				end

				set_default_size 300, 300
				set_window_position Gtk::Window::POS_CENTER

				@box = Gtk::VBox.new(false, 10)

				add_box_controls(@box)

				button = Gtk::Button.new("Clear")
				button.signal_connect "clicked" do
					clear_canvas
				end
				@box.pack_end(button, false, false)
				button.show

				@area = Gtk::DrawingArea.new
				@area.set_size_request 200, 200
				@area.signal_connect :expose_event do
					canvas_expose_event
				end

				@area.signal_connect :configure_event do
					clear_canvas if !@pixmap
				end

				@area.signal_connect :motion_notify_event do |widget, event|
					x, y, state = event.x, event.y, event.state
					if event.hint?
						_, x, y, state = event.window.pointer
					end

					if state.button1_mask? && @pixmap
						draw_brush(x, y)
					end
				end

				@area.signal_connect "button_press_event" do |widget, event|
					if event.button == 1 && @pixmap
						draw_brush(event.x, event.y)
					end
				end

				@area.events = Gdk::Event::EXPOSURE_MASK |
					Gdk::Event::LEAVE_NOTIFY_MASK |
					Gdk::Event::BUTTON_PRESS_MASK |
					Gdk::Event::POINTER_MOTION_MASK |
					Gdk::Event::POINTER_MOTION_HINT_MASK
				@box.pack_start(@area, true, true)
				@area.show

				add @box

				@box.show
				show
			end
		end
	end
end
