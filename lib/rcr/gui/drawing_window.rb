require 'gtk2'
require 'rcr/logging'
require 'rcr/gui/letter_drawing_area'

module RCR
	module GUI
		class DrawingWindow < Gtk::Window
			include Logging

			def add_box_controls(box)
				# Not implemented.
			end

			def title
				"(title not set)"
			end

			def initialize(classifier = nil)
				super()

				set_title title
				signal_connect "destroy" do
					Gtk.main_quit
				end

				set_default_size 300, 300
				set_window_position Gtk::Window::POS_CENTER

				@box = Gtk::VBox.new(false, 10)

				add_box_controls(@box)

				button = Gtk::Button.new("Clear")
				button.signal_connect :clicked do
					@area.clear
				end
				@box.pack_end(button, false, false)
				button.show

				fixed = Gtk::Fixed.new

				@area = RCR::GUI::LetterDrawingArea.new(classifier)
				@area.set_size_request 256, 256

				fixed.put(@area, 0, 0)
				@area.show

				@box.pack_start(fixed, true, true)
				fixed.show

				add @box

				@box.show
				show
			end
		end
	end
end
