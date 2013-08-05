require 'kgr/data/image'
require 'kgr/letter-classifier/neural'
require 'kgr/gui/drawing-window'

# TODO: "make new sample" button

module KGR
	module GUI
		class ClassifyLetter
			class Window < KGR::GUI::DrawingWindow
				def initialize(classify_letter)
					super()
					@classify_letter = classify_letter
				end

				def classify
					@letter = @classifier.classify(KGR::Data::Image.from_pixmap(pixmap)).chr
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

			def initialize(classifier_path)
				@classifier = LetterClassifier::Neural.load(classifier_path)
			end

			def run
				Gtk.init
				KGR::GUI::ClassifyLetter::Window.new(self)
				Gtk.main
			end
		end
	end
end
