#####################################################################################
# gradient.rb                                                            11.29.2014
#
# Ruby Gradient Generator
#   author: Jeff Miller
#   website: humani.se
#   github: github.com/ibanez270dx
#
#   USAGE:
#     Enter RGB or Hex color values and number of steps
#
#     yellow = [ 255, 246, 0 ]
#     orange = "#ff9000"
#     pink = [ 255, 56, 192 ]
#     violet = "#29aa59"
#
#     gradient = Gradient.new(colors: [ yellow, orange, pink, violet ], steps: 100)
#     gradient.print
#
#####################################################################################

class Gradient

  def initialize(options)
    options = { steps: 10 }.merge(options)
    @steps = options[:steps]-1 # Minus one to make room for the final breakpoint
    @colors = options[:colors].collect { |color| to_rgb(color) }

    @gradient_count = @colors.length-1      # Number of gradients to calculate
    @substeps = @steps / @gradient_count    # Substeps per gradient
    @remainder = @steps % @gradient_count   # Remaining steps
  end

  def generate
    @gradient_count.times.inject([]) do |memo, index|
      steps = @substeps
      if @remainder > 0      # Add a step if there are leftovers still
        steps += 1
        @remainder -= 1
      end

      memo += gradient_for(@colors[index], @colors[index+1], steps)
      memo
    end.push(@colors.last)
  end

  def hex
    # Returns an array of hex color values
    generate.collect do |color|
      to_hex(color)
    end
  end

  def rgb
    # Returns an array of RGB value arrays
    generate.collect do |color|
      color.collect(&:to_i)
    end
  end

  def print
    puts "Breakpoints:"
    @colors.each do |color|
      puts "  #{color[0]}, #{color[1]}, #{color[2]}"
    end

    puts "\nIn #{@steps+1} Steps:"
    generate.each_with_index do |color, i|
      puts "  #{i+1} :: #{to_hex(color)} :: #{color[0].to_i}, #{color[1].to_i}, #{color[2].to_i} #{' (breakpoint)' if @colors.include?(color)}"
    end
  end

  private

    def gradient_for(color1, color2, steps)
      # Calculate a single color-to-color gradient
      steps.times.inject([]) do |memo, index|
        ratio = index.to_f / steps
        r = color2[0] * ratio + color1[0] * (1 - ratio)
        g = color2[1] * ratio + color1[1] * (1 - ratio)
        b = color2[2] * ratio + color1[2] * (1 - ratio)
        memo.push [ r, g, b ]
        memo
      end
    end

    def is_rgb?(color)
      # Returns true for the form [ 123, 123, 123 ]
      color.is_a?(Array) && color.length==3 && !color.collect{ |c| !!(c.to_i.to_s=~/^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$/) }.include?(false)
    end

    def is_hex?(color)
      # Returns true for the form "#ffe100"
      color.is_a?(String) && !!(color=~/^#[a-fA-F0-9]{6}$/)
    end

    def to_rgb(color)
      # Converts color to an RGB value
      case
      when is_rgb?(color) then color
      when is_hex?(color) then [ color[1..2].hex, color[3..4].hex, color[5..6].hex ]
      else raise "#{color.inspect} is not a valid RGB or Hex color"
      end
    end

    def to_hex(color)
      # Converts color to a Hex value
      case
      when is_hex?(color) then color
      when is_rgb?(color)
        color.inject("#") do |memo, value|
          str = value.to_i.to_s(16)
          hex = str.length==1 ? str.concat(str) : str
          memo.concat(hex)
          memo
        end
      else raise "#{color.inspect} is not a valid RGB or Hex color"
      end
    end
end
