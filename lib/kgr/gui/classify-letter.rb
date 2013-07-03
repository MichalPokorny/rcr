require 'gtk2'

module KGR
	module GUI
		class ClassifyLetter
			class MainWindow < Gtk::Window
				def classify
					puts "Classify..."
				end

				def clear_canvas
					puts "Clear canvas..."
				end

				def canvas_expose_event
					#window = @area.window
					#gc = window.new_gc

					#layout = @area.create_pango_layout "Ahoj svete"
					#layout.font_description = pango.
				end

				def initialize
					super

					set_title "Letter classifier"
					signal_connect "destroy" do
						Gtk.main_quit
					end

					set_default_size 300, 300
					set_window_position Gtk::Window::POS_CENTER

					@box = Gtk::VBox.new(false, 10)

					button = Gtk::Button.new("Classify")
					button.connect "clicked" do
						classify
					end
					@box.pack_end(button, false, false)
					button.show

					button = Gtk::Button.new("Clear")
					button.connect "clicked" do
						clear_canvas
					end
					button.show

					@area = Gtk::DrawingArea.new
					@area.set_size_request 200, 200
					@area.connect "expose_event" do
						canvas_expose_event
					end

					#@area.connect "configure_event" do
					#	self.configure_event
					#end

					#@area.connect "motion_notify_event" do
					#	self.motion_notify_event
					#end

					#@area.connect "button_press_event" do
					#	self.button_press_event
					#end
				
					@area.events = Gdk::GdkEventMask.EXPOSURE_MASK |
						Gdk::GdkEventMask.LEAVE_NOTIFY_MASK |
						Gdk::GdkEventMask.BUTTON_PRESS_MASK |
						Gdk::GdkEventMask.POINTER_MOTION_MASK |
						Gdk::GdkEventMask.POINTER_MOTION_HINT_MASK
					@box.pack_start(@area, true, true)
					@area.show

					add @box
					
					@box.show
					show
				end
			end

			def run
				Gtk.init
				MainWindow.new
				Gtk.main
			end
		end
	end
end
