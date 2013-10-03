require 'kgr/logging'
require 'kgr/data/image'
require 'kgr/data/pixmap-imagelike'
require 'kgr/letter-classifier/neural'
require 'kgr/gui/drawing-window'

# TODO: "make new sample" button

module KGR
	module GUI
		class ClassifyLetter
			class Window < KGR::GUI::DrawingWindow
				include Logging

				def initialize(classifier)
					super()
					@classifier = classifier
					@letter = nil
				end

				def classify
					log "classifying... (pixmap size: #{@pixmap.size.inspect})..."
					@letter = @classifier.classify(PixmapImagelike.new(@pixmap)).chr
					log "finished"
					@area.queue_draw_area 0, 0, *@pixmap.size
				end

				def add_box_controls(box)
					button = Gtk::Button.new("Classify")
					button.signal_connect "clicked" do
						classify
					end
					box.pack_end(button, false, false)
					button.show
				end

				def title
					"Letter classifier"
				end

				def draw_on_area(area)
					if @letter
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
				window = KGR::GUI::ClassifyLetter::Window.new(@classifier)
				window.enable_logging = true
				Gtk.main
			end
		end
	end
end
