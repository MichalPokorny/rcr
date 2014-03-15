require 'rcr/config'
require 'rcr/letter_classifier/neural'
require 'rcr/data/image'

module RCR
	def self.extract_config!(opts)
		if opts.key?(:config)
			opts.delete(:config)
		elsif opts.key?(:config_file)
			RCR::Config.load_from_file(opts.delete(:config_file))
		else
			RCR::Config.instance
		end
	end
	private_class_method :extract_config!

	def self.build_letter_classifier(opts = {})
		RCR::Marshal.load(extract_config!(opts).letter_classifier_path)
	end

	def self.build_language_model(opts = {})
		RCR::Marshal.load(extract_config!(opts).language_model_path)
	end

	def self.build_word_segmentator(opts = {})
		require 'rcr/word_segmentator/heuristic_oversegmentation'
		require 'rcr/heuristic_oversegmenter/local_minima'
		# TODO: load the segmentator we should actually load!
		#
		# Old: Stupid instead of LocalMinima
		RCR::WordSegmentator::HeuristicOversegmentation.new(RCR::HeuristicOversegmenter::LocalMinima.new, build_letter_classifier, build_language_model)
	end

	def self.load_image(filename)
		RCR::Data::Image.load(filename)
	end

	def self.load_image_from_blob(blob)
		RCR::Data::Image.from_blob(blob)
	end
end
