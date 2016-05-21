# -*- encoding: utf-8 -*-

require 'spec_helper'

describe TransactionSampleDatum do

  # TODO: auto-generated
  describe '#ancestors' do
    it 'works' do
      transaction_sample_datum = create(:transaction_sample_datum)
      result = transaction_sample_datum.ancestors
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parent_of?' do
    it 'works' do
      transaction_sample_datum1= create(:transaction_sample_datum)
      transaction_sample_datum2 = create(:transaction_sample_datum)
      result = transaction_sample_datum1.parent_of?(transaction_sample_datum2)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#child_of?' do
    it 'works' do
      transaction_sample_datum1 = create(:transaction_sample_datum)
      transaction_sample_datum2 = create(:transaction_sample_datum)
      result = transaction_sample_datum1.child_of?(transaction_sample_datum2)
      expect(result).not_to be_nil
    end
  end

end
