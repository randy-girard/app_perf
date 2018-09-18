# frozen_string_literal: true

class HdrHistogram
  class Snapshot
    attr_accessor :lowestTrackableValue,
                  :highestTrackableValue,
                  :significantFigures,
                  :counts

    def initialize(hash = {})
      @lowestTrackableValue = hash[:lowestTrackableValue]
      @highestTrackableValue = hash[:highestTrackableValue]
      @significantFigures = hash[:significantFigures]
      @counts = hash[:counts]
    end
  end

  class Bar
    attr_accessor :from,
                  :to,
                  :count

    def initialize(hash = {})
      @from = hash[:from]
      @to = hash[:to]
      @count = hash[:count]
    end

    def string
      puts "#{@from}, #{@to}, #{@count}"
    end
  end

  class Iterator
    attr_accessor :h,
                  :bucketIdx, :subBucketIdx,
                  :countAtIdx, :countToIdx, :valueFromIdx,
                  :highestEquivalentValue

    def initialize(hash = {})
      @h = hash[:h]
      @bucketIdx = hash[:bucketIdx].to_i
      @subBucketIdx = hash[:subBucketIdx].to_i
      @countAtIdx = hash[:countAtIdx].to_i
      @countToIdx = hash[:countToIdx].to_i
      @valueFromIdx = hash[:valueFromIdx].to_i
      @highestEquivalentValue = hash[:highestEquivalentValue].to_i
    end

    def next
      if @countToIdx.to_i >= @h.totalCount.to_i
        return false
      end

      @subBucketIdx += 1
      if @subBucketIdx.to_i >= @h.subBucketCount.to_i
        @subBucketIdx = @h.subBucketHalfCount.to_i
        @bucketIdx = @bucketIdx.to_i + 1
      end

      if @bucketIdx.to_i >= @h.bucketCount.to_i
        return false
      end

      @countAtIdx = @h.getCountAtIndex(@bucketIdx, @subBucketIdx)
      @countToIdx = @countToIdx.to_i + @countAtIdx.to_i
      @valueFromIdx = @h.valueFromIndex(@bucketIdx, @subBucketIdx)
      @highestEquivalentValue = @h.highestEquivalentValue(@valueFromIdx)

      return true
    end
  end

  class RIterator < Iterator
    attr_accessor :iterator,
                  :countAddedThisStep

    def initialize(hash = {})
      @iterator = hash[:iterator]
      @countAddedThisStep = hash[:countAddedThisStep].to_i
    end

    def next
      while @iterator.next
        if @iterator.countAtIdx.to_i != 0
          @countAddedThisStep = @iterator.countAtIdx
          return true
        end
      end

      return false
    end
  end

  class QIterator < Iterator
    attr_accessor :iterator,
                  :seenLastValue,
                  :quantiles,
                  :percentileToIteratorTo,
                  :percentile

    def initialize(hash = {})
      @iterator = hash[:iterator]
      @seenLastValue = hash[:seenLastValue] || false
      @percentileToIteratorTo = hash[:percentileToIteratorTo].to_f
      @percentile = hash[:percentile].to_f
      @quantiles = hash[:quantiles] || []
      @index = 0
    end

    def next
      if !(@iterator.countToIdx.to_i < @iterator.h.totalCount.to_i)
        if @seenLastValue
          return false
        end

        @seenLastValue = true
        @percentile = 100
      end

      if @iterator.subBucketIdx == -1 && !@iterator.next
        return false
      end

      done = false

      while !done
        currentPercentile = (100.to_f * @iterator.countToIdx.to_f) / @iterator.h.totalCount.to_f

        if @quantiles[@index] == nil
          return false
        elsif @iterator.countAtIdx != 0 && @quantiles[@index] <= currentPercentile
          @percentile = @quantiles[@index]
          @percentileToIteratorTo = @quantiles[@index + 1]
          @index += 1
          return true
        end
        done = !@iterator.next
      end

      return true
    end
  end

  class PIterator < Iterator
    attr_accessor :iterator,
                  :seenLastValue,
                  :ticksPerHalfDistance,
                  :percentileToIteratorTo,
                  :percentile,
                  :quantiles

    def initialize(hash = {})
      @iterator = hash[:iterator]
      @seenLastValue = hash[:seenLastValue] || false
      @ticksPerHalfDistance = hash[:ticksPerHalfDistance].to_i
      @percentileToIteratorTo = hash[:percentileToIteratorTo].to_f
      @percentile = hash[:percentile].to_f
    end

    def next
      if !(@iterator.countToIdx.to_i < @iterator.h.totalCount.to_i)
        if @seenLastValue
          return false
        end

        @seenLastValue = true
        @percentile = 100
      end

      if @iterator.subBucketIdx == -1 && !@iterator.next
        return false
      end

      done = false

      while !done
        currentPercentile = (100.to_f * @iterator.countToIdx.to_f) / @iterator.h.totalCount.to_f
        if @iterator.countAtIdx != 0 && @percentileToIteratorTo <= currentPercentile
          @percentile = @percentileToIteratorTo
          halfDistance = (2 ** (Math.log2(100.to_f / (100.to_f - @percentileToIteratorTo) ) ) + 1).to_f
          percentileReportingTicks = @ticksPerHalfDistance.to_f * halfDistance
          @percentileToIteratorTo = @percentileToIteratorTo + (100.to_f / percentileReportingTicks)
          return true
        end
        done = !@iterator.next
      end

      return true
    end
  end

  attr_accessor :lowestTrackableValue,
                :highestTrackableValue,
                :significantFigures,
                :subBucketHalfCountMagnitude,
                :unitMagnitude,
                :subBucketMask,
                :subBucketCount,
                :subBucketHalfCount,
                :bucketCount,
                :countsLen,
                :totalCount,
                :counts

  def initialize(min_value, max_value, sigfigs)
    @lowestTrackableValue = min_value
    @highestTrackableValue = max_value
    @significantFigures = sigfigs

    if sigfigs < 1 || 5 < sigfigs
  		puts "sigfigs must be [1,5] (was %d)" % sigfigs
  	end

    largestValueWithSingleUnitResolution = 2 * (10 ** sigfigs)
    subBucketCountMagnitude = Math.log2(largestValueWithSingleUnitResolution).ceil

    @subBucketHalfCountMagnitude = subBucketCountMagnitude
  	if @subBucketHalfCountMagnitude < 1
  		@subBucketHalfCountMagnitude = 1
  	end
  	@subBucketHalfCountMagnitude -= 1

    @unitMagnitude = Math.log2(min_value).floor rescue 0
  	if @unitMagnitude < 0
  		@unitMagnitude = 0
  	end

    @subBucketCount = 2 ** (@subBucketHalfCountMagnitude + 1)

  	@subBucketHalfCount = @subBucketCount / 2
  	@subBucketMask = (@subBucketCount-1) << @unitMagnitude

  	smallestUntrackableValue = @subBucketCount << @unitMagnitude
  	bucketsNeeded = 1
  	while smallestUntrackableValue < max_value
  		smallestUntrackableValue = smallestUntrackableValue << 1
  		bucketsNeeded += 1
  	end

  	@bucketCount = bucketsNeeded
  	@countsLen = (@bucketCount + 1) * (@subBucketCount / 2)
    @totalCount = 0
    @counts = Array.new(@countsLen, 0)
  end

  def byteSize
    (6 * 8) + (5 * 4) + @counts.length
  end

  def merge(from)
    dropped = 0

    i = from.rIterator
    while i.next
      v = i.iterator.valueFromIdx
      c = i.iterator.countAtIdx
      if recordValues(v, c) != nil
        dropped += c
      end
    end

    return dropped
  end

  def totalCount
    @totalCount
  end

  def max
  	max = 0
    i = iterator
  	while i.next
  		if i.countAtIdx != 0
  			max = i.highestEquivalentValue
  		end
  	end
  	highestEquivalentValue(max)
  end

  def min
  	min = 0
    i = iterator
  	while i.next
  		if i.countAtIdx != 0 && min == 0
  			min = i.highestEquivalentValue
  			break
  		end
    end
  	lowestEquivalentValue(min)
  end

  def mean
  	if @totalCount == 0
  		return 0
  	end

  	total = 0
  	i = iterator
  	while i.next
  		if i.countAtIdx != 0
  			total = total.to_i + (i.countAtIdx.to_i * medianEquivalentValue(i.valueFromIdx))
  		end
    end

    total.to_f / @totalCount.to_f
  end

  def stdDev
  	if @totalCount == 0
  		return 0
  	end

  	_mean = mean
  	geometricDevTotal = 0.0

  	i = iterator
  	while i.next
  		if i.countAtIdx != 0
  			dev = medianEquivalentValue(i.valueFromIdx).to_f - _mean
  			geometricDevTotal += (dev * dev) * i.countAtIdx.to_f
  		end
    end

    Math.sqrt(geometricDevTotal / @totalCount.to_f)
  end

  def reset
    @totalCount = 0
    for i in (0..@counts.length)
      @counts[i] = 0
    end
  end

  def recordValue(v)
    recordValues(v, 1)
  end

  def recordCorrectedValue(v, expectedInterval)
  	if err = recordValue(v) && err != nil
  		return err
  	end

  	if expectedInterval <= 0 || v <= expectedInterval
  		return nil
  	end

  	missingValue = v - expectedInterval
  	while missingValue >= expectedInterval
  		if err = h.RecordValue(missingValue) && err != nil
  			return err
  		end
  		missingValue -= expectedInterval
  	end

  	return nil
  end

  def recordValues(v, n)
  	idx = countsIndexFor(v)
  	if idx < 0 || @countsLen.to_i <= idx
      puts "value #{v} is too large to be recorded"
      return nil
  	end

  	@counts[idx] = @counts[idx].to_i + n
  	@totalCount = @totalCount.to_i + n

  	return nil
  end

  def valueAtQuantile(q)
  	if q > 100
  		q = 100
  	end

  	total = 0
  	countAtPercentile = ((q / 100.to_f) * @totalCount.to_f) + 0.5

  	i = iterator
  	while i.next
  		total = total + i.countAtIdx.to_i
  		if total >= countAtPercentile
  			return highestEquivalentValue(i.valueFromIdx)
      end
    end

  	return 0
  end

  def cumulativeDistribution
    result = Array.new

    i = pIterator(1)

  	while i.next
  		result << {
  			quantile: i.percentile,
  			count:    i.iterator.countToIdx,
  			valueAt:  i.iterator.highestEquivalentValue,
  		}
  	end

  	return result
  end

  def specificDistribution(quantiles = [50.0, 75.0, 90.0, 95.0, 99.0])
    result = Array.new

    i = qIterator(quantiles)

  	while i.next
  		result << {
  			quantile: i.percentile,
  			count:    i.iterator.countToIdx,
  			valueAt:  i.iterator.highestEquivalentValue,
  		}
  	end

  	return result
  end

  def significantFigures
  	@significantFigures
  end

  def lowestTrackableValue
  	@lowestTrackableValue
  end

  def highestTrackableValue
  	@highestTrackableValue
  end

  def distribution
    result = Array.new

  	i = iterator
  	while i.next
  		result << Bar.new(
  			count: i.countAtIdx.to_i,
  			from:  lowestEquivalentValue(i.valueFromIdx),
  			to:    i.highestEquivalentValue
  		)
  	end

  	return result
  end

  def equals(other)
    if @lowestTrackableValue != other.lowestTrackableValue ||
       @highestTrackableValue != other.highestTrackableValue ||
       @unitMagnitude != other.unitMagnitude ||
       @significantFigures != other.significantFigures ||
       @subBucketHalfCountMagnitude != other.subBucketHalfCountMagnitude ||
       @subBucketHalfCount != other.subBucketHalfCount ||
       @subBucketMask != other.subBucketMask ||
       @subBucketCount != other.subBucketCount ||
       @bucketCount != other.bucketCount ||
       @countsLen != other.countsLen ||
       @totalCount != other.totalCount
      return false
    else
      if @counts != other.counts
        return false
      end
    end

  	return true
  end

  def export
    Snapshot.new(
      lowestTrackableValue: @lowestTrackableValue,
      highestTrackableValue: @highestTrackableValue,
      significantFigures: @significantFigures,
      counts: @counts.dup
    )
  end

  def self.import(data)
    counts = data.pop

    histogram = new(*data)
    histogram.counts = counts
    totalCount = 0

    for i in 0..histogram.countsLen
      countAtIndex = histogram.counts[i]
      if countAtIndex && countAtIndex > 0
        totalCount += countAtIndex
      end
    end

    histogram.totalCount = totalCount

    return histogram
  end

  def iterator
    Iterator.new(h: self.dup, subBucketIdx: -1)
  end

  def rIterator
    RIterator.new(iterator: iterator)
  end

  def pIterator(ticksPerHalfDistance)
    PIterator.new(
      iterator: iterator,
      ticksPerHalfDistance: ticksPerHalfDistance
    )
  end

  def qIterator(quantiles)
    QIterator.new(
      iterator: iterator,
      quantiles: quantiles
    )
  end

  def sizeOfEquivalentValueRange(v)
  	bucketIdx = getBucketIndex(v)
  	subBucketIdx = getSubBucketIdx(v, bucketIdx)
  	adjustedBucket = bucketIdx.to_i
  	if subBucketIdx.to_i >= @subBucketCount.to_i
  		adjustedBucket += 1
  	end

    1 << @unitMagnitude + adjustedBucket
  end

  def valueFromIndex(bucketIdx, subBucketIdx)
  	subBucketIdx << bucketIdx.to_i + @unitMagnitude
  end

  def lowestEquivalentValue(v)
  	bucketIdx = getBucketIndex(v)
  	subBucketIdx = getSubBucketIdx(v, bucketIdx)
  	valueFromIndex(bucketIdx, subBucketIdx)
  end

  def nextNonEquivalentValue(v)
  	lowestEquivalentValue(v) + sizeOfEquivalentValueRange(v)
  end

  def highestEquivalentValue(v)
  	nextNonEquivalentValue(v) - 1
  end

  def medianEquivalentValue(v)
  	lowestEquivalentValue(v) + (sizeOfEquivalentValueRange(v) >> 1)
  end

  def getCountAtIndex(bucketIdx, subBucketIdx)
  	@counts[countsIndex(bucketIdx, subBucketIdx)]
  end

  def countsIndex(bucketIdx, subBucketIdx)
  	bucketBaseIdx = (bucketIdx.to_i + 1) << @subBucketHalfCountMagnitude
  	offsetInBucket = subBucketIdx - @subBucketHalfCount
  	bucketBaseIdx + offsetInBucket
  end

  def getBucketIndex(v)
  	pow2Ceiling = bitLen(v | @subBucketMask)
  	(pow2Ceiling - @unitMagnitude) - (@subBucketHalfCountMagnitude + 1)
  end

  def getSubBucketIdx(v, idx)
    v >> idx + @unitMagnitude
  end

  def countsIndexFor(v)
  	bucketIdx = getBucketIndex(v)
  	subBucketIdx = getSubBucketIdx(v, bucketIdx)
  	countsIndex(bucketIdx, subBucketIdx)
  end

  def bitLen(x)
    n = 0

  	while x >= 0x8000
      x = x >> 16
  		n += 16
  	end

    if x >= 0x80
  		x = x >> 8
  		n += 8
  	end

  	if x >= 0x8
  		x = x >> 4
  		n += 4
  	end

  	if x >= 0x2
  		x = x >> 2
  		n += 2
  	end

  	if x >= 0x1
  		n += 1
  	end

  	return n
  end
end
