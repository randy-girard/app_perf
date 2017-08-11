# -*- encoding: utf-8 -*-

require 'spec_helper'

describe Span do

  # TODO: auto-generated
  describe '#ancestors' do
    it 'works' do
      span = create(:span)
      result = span.ancestors
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parent_of?' do
    it 'works' do
      span1 = create(:span, :timestamp => Time.now - 5.minutes, :duration => 10.minutes)
      span2 = create(:span, :timestamp => Time.now - 3.minutes, :duration => 5.minutes)
      result = span1.parent_of?(span2)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#child_of?' do
    it 'works' do
      span1 = create(:span, :timestamp => Time.now - 3.minutes, :duration => 5.minutes)
      span2 = create(:span, :timestamp => Time.now - 5.minutes, :duration => 10.minutes)
      result = span1.child_of?(span2)
      expect(result).not_to be_nil
    end
  end

end
