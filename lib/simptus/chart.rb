require 'lazy_high_charts'
include LazyHighCharts::LayoutHelper

module Simptus
  module Chart
    def self.create(title, data, time, yaxis)
      colors = %w(#008080 #ff4500 #7fff00 #9400d3 #800000)
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title({ text: title })
        f.options[:xAxis][:categories] = time
        f.labels(item:
                 [style: { left: '10px', top: '8px', color: 'black' }])
        data.each_key do |k|
          color = colors.shift
          f.series(type: 'spline', name: k,
                   data: data[k], color: color)
        end
        f.chart(width: 1000)
        f.yAxis(max: yaxis)
      end
    end
  end
end
