DROP FUNCTION hdr_histogram(histogram histogram);
CREATE OR REPLACE FUNCTION hdr_histogram(histogram histogram) RETURNS hdrHistogram AS $$
  DECLARE
    lowestTrackableValue integer;
    highestTrackableValue integer;
    significantFigures integer;

    largestValueWithSingleUnitResolution integer;
    subBucketCountMagnitude integer;
    subBucketHalfCountMagnitude integer;
    unitMagnitude integer;
    subBucketCount integer;
    subBucketHalfCount integer;
    subBucketMask integer;
    smallestUntrackableValue integer;
    bucketsNeeded integer;
    bucketCount integer;
    countsLen integer;
    totalCount integer;
    countAtIndex integer;

    output hdrHistogram;
    counts integer[];
  BEGIN
    output.lowestTrackableValue := histogram.minValue;
    output.highestTrackableValue := histogram.maxValue;
    output.significantFigures := histogram.significantFigures;

    IF (output.significantFigures < 1 OR 5 < output.significantFigures) THEN
  	 	RAISE NOTICE 'significantFigures must be [1,5] (was %)', output.significantFigures;
  	END IF;

    largestValueWithSingleUnitResolution := 2 * POWER(10, output.significantFigures);
    subBucketCountMagnitude := ceil(log(2, largestValueWithSingleUnitResolution));

    subBucketHalfCountMagnitude := subBucketCountMagnitude;
  	IF subBucketHalfCountMagnitude < 1 THEN
  		subBucketHalfCountMagnitude := 1;
  	END IF;

  	subBucketHalfCountMagnitude := subBucketHalfCountMagnitude - 1;

    IF output.lowestTrackableValue > 0 THEN
      unitMagnitude := floor(log(2, output.lowestTrackableValue));
    ELSE
      unitMagnitude := 0;
    END IF;

  	IF unitMagnitude < 0 THEN
  		unitMagnitude := 0;
  	END IF;

    subBucketCount := POWER(2, (subBucketHalfCountMagnitude + 1));

  	subBucketHalfCount := subBucketCount / 2;
  	subBucketMask := ((subBucketCount - 1) << unitMagnitude);

  	smallestUntrackableValue := subBucketCount << unitMagnitude;
  	bucketsNeeded := 1;
  	WHILE smallestUntrackableValue < output.highestTrackableValue LOOP
  		smallestUntrackableValue := smallestUntrackableValue << 1;
  		bucketsNeeded := bucketsNeeded + 1;
  	END LOOP;

  	bucketCount := bucketsNeeded;
  	countsLen := (bucketCount + 1) * (subBucketCount / 2);

    totalCount := 0;

    FOR i in 0..countsLen LOOP
      output.counts[i] := COALESCE(histogram.counts[i], 0);
      countAtIndex := output.counts[i];
      IF countAtIndex IS NOT NULL AND countAtIndex > 0 THEN
        totalCount := totalCount + countAtIndex;
      END IF;
    END LOOP;

    output.subBucketHalfCountMagnitude := COALESCE(subBucketHalfCountMagnitude, 0);
    output.subBucketHalfCount := COALESCE(subBucketHalfCount, 0);
    output.unitMagnitude := COALESCE(unitMagnitude, 0);
    output.subBucketMask := COALESCE(subBucketMask, 0);
    output.subBucketCount := COALESCE(subBucketCount, 0);
    output.totalCount := COALESCE(totalCount, 0);
    output.bucketCount := COALESCE(bucketCount, 0);
    output.countsLen := COALESCE(countsLen, 0);

    RETURN output;
  END;
$$ LANGUAGE plpgsql STABLE;
