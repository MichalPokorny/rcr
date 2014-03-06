require 'rcr/logging'
require 'rcr/data/image'
require 'rcr/data/pixmap_imagelike'
require 'rcr/gui/drawing_window'

# TODO: "make new sample" button

module RCR
	module GUI
		class ClassifyLetter
			class Window < RCR::GUI::DrawingWindow
				include Logging

				def initialize(classifier)
					super(classifier)
					@letter = nil

					@area.overlays << self
				end

				def add_box_controls(box)
					button = Gtk::Button.new("Classify")
					button.signal_connect :clicked do
						@drawn_letter = @area.drawn_letter
						log "#{@area.drawn_letter_variants.inspect}"
						log "Drawn letter: #@drawn_letter"
						@area.queue_draw_area 0, 0, @area.allocation.width, @area.allocation.height
					end
					box.pack_end(button, false, false)
					button.show
				end

				def title
					"Letter classifier"
				end

				def draw_on_area(area)
					if @letter
						puts "Vykreslim to."
						layout = Pango::Layout.new Gdk::Pango.context
						layout.font_description = Pango::FontDescription.new('Sans 14')
						layout.text = "Detected: #@letter"
						area.window.draw_layout(area.style.fg_gc(Gtk::STATE_NORMAL), 30, window_height + 20, layout)
					end
				end
			end

			def initialize(classifier)
				@classifier = classifier
			end

			def run
				Gtk.init
				window = RCR::GUI::ClassifyLetter::Window.new(@classifier)
				window.enable_logging = true
				Gtk.main
			end
		end
	end
end