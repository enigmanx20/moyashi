module SpectrumUtil
  module Converter
    # filter to detect header of raw data
    Filter = /Profile\sData\n
    \#\sof\sPoints\s?[0-9]+\n
    m\/z\tAbsolute\ Intensity\tRelative\ Intensity\n
    (.*)\n\n/xm



    module_function
    def normalize_raw_data(input)
      # pick up spectrum data by regular expression
      Filter =~ input.gsub(/\r\n?/, "\n")

      # convert
      spectrum = $1.chomp.split("\n").map{|v| v.split("\t")[0..1] }
      spectrum.unshift(["m/z", nil])
      spectrum = spectrum.transpose.map{|v| v.join(",") }.join("\n")

      spectrum
    end
  end
end