require 'gtk2'

require 'kgr/data/image'
require 'kgr/letter-classifier/neural'

module KGR
	module GUI
		class ClassifyLetter
			class MainWindow < Gtk::Window
				def classify
					w, h = @pixmap.size
					image = @pixmap.get_image 0, 0, w, h

					pixels = (0...window_size).map { |x|
						(0...window_size).map { |y|
							pixel = image.get_pixel(x, y)

							# TODO: universalize!
							b = pixel & 0xFF; pixel >>= 8
							g = pixel & 0xFF; pixel >>= 8
							r = pixel & 0xFF

							[ r, g, b ]
						}
					}

					result = @classify_letter.classify(pixels)		

					puts "Result: #{result}"
				end

				def clear_canvas
					width, height = @area.allocation.width, @area.allocation.height

					puts "width #{width} height #{height}"

					@pixmap = Gdk::Pixmap.new(@area.window, width, height, -1)
					@pixmap.draw_rectangle(@area.style.white_gc, true, 0, 0, width, height)
					w, h = @pixmap.size

					@area.queue_draw_area 0, 0, w, h
				end

				def window_size
					256
				end

				def canvas_expose_event
					w, h = @pixmap.size

					@area.window.draw_drawable(@area.style.fg_gc(Gtk::STATE_NORMAL),
						@pixmap, 0, 0, 0, 0, w, h)

					@area.window.draw_rectangle @area.style.black_gc, false, 0, 0, window_size, window_size
				end

				def brush_size
					8
				end

				def draw_brush(x, y)
					b = brush_size / 2
					rect = [(x-b).floor, (y-b).floor, b*2, b*2]
					@pixmap.draw_rectangle(@area.style.black_gc, true, *rect)
					@area.queue_draw_area(*rect)
				end

				def initialize(classify_letter)
					super()

					@classify_letter = classify_letter

					set_title "Letter classifier"
					signal_connect "destroy" do
						Gtk.main_quit
					end

					set_default_size 300, 300
					set_window_position Gtk::Window::POS_CENTER

					@box = Gtk::VBox.new(false, 10)

					button = Gtk::Button.new("Classify")
					button.signal_connect "clicked" do
						classify
					end
					@box.pack_end(button, false, false)
					button.show

					button = Gtk::Button.new("Clear")
					button.signal_connect "clicked" do
						clear_canvas
					end
					@box.pack_end(button, false, false)
					button.show

					@area = Gtk::DrawingArea.new
					@area.set_size_request 200, 200
					@area.signal_connect "expose_event" do
						canvas_expose_event
					end

					@area.signal_connect "configure_event" do
						clear_canvas
					end

					@area.signal_connect "motion_notify_event" do |widget, event|
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

			def initialize
				# TODO tfuj
				@classifier = LetterClassifier::Neural.load("letter-classifier.net")
			end

			def run
				Gtk.init
				MainWindow.new(self)
				Gtk.main
			end

			# pixels: 2D array of R-G-B pixels (0..256)
			def classify(pixels)
				img = Data::Image.from_pixel_block(pixels)

				@classifier.index_to_letter(@classifier.classify(img))
			end
		end
	end
end
