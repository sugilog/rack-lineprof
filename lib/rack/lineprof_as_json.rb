require "json"

module Rack
  class LineprofAsJSON < Lineprof
    def output profile
      logger  = options[:logger] || ::Logger.new(STDOUT)

      STDOUT.puts profile
      format_profile(profile).each do |_profile|
        STDOUT.puts _profile
        logger.debug Lineprof::PREFIX + " " + _profile.to_json
      end
    end

    def format_profile profile
      timestamp = Time.now.to_i
      formatted = []

      sources = profile.map do |filename, samples|
        Source.new filename, samples, options
      end

      sources.each do |source|
        source.samples.each do |sample|
          formatted << {
            timestamp: timestamp,
            file:  source.filename.sub(Dir.pwd + "/", ""),
            ms:    sample.ms,
            calls: sample.calls,
            line:  sample.line,
            code:  sample.code,
            level: sample.level
          }
        end
      end

      formatted
    end
  end
end
