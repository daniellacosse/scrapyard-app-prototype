module CoreExtensions
  module Enumerable
    module Stats
      def sum
        inject(0) { |accum, i| accum + i.to_i }
      end

      def mean
        sum / length.to_f
      end

      def sample_variance
        m = mean
        sum = inject(0) { |accum, i| accum + (i.to_i - m)**2 }
        sum / (length - 1).to_f
      end

      def standard_deviation
        Math.sqrt sample_variance
      end
    end
  end
end
