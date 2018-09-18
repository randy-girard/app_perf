#include "postgres.h"
#include "executor/executor.h"
#include "fmgr.h"
#include "utils/jsonb.h"
#include "catalog/pg_type.h"
#include "miscadmin.h"
#include "libpq/pqformat.h"
#include <math.h>

#define MAX_COUNT_SIZE 512

typedef struct HdrHistogram {
  int _size;
  int32 lowestTrackableValue;
  int32 highestTrackableValue;
  int32 unitMagnitude;
  int32 significantFigures;
  int32 subBucketHalfCountMagnitude;
  int32 subBucketHalfCount;
  int32 subBucketMask;
  int32 subBucketCount;
  int32 bucketCount;
  int32 countsLen;
  int32 totalCount;
  int32 counts[1];
} HdrHistogram;

typedef struct iterator {
  HdrHistogram *h;
  int32 bucketIdx;
  int32 subBucketIdx;
  int64 countAtIdx;
  int64 countToIdx;
  int64 valueFromIdx;
  int64 highestEquivalentValue;
} iterator;

int hdr_c_bitLen(int x);
int hdr_c_countsIndexFor(HdrHistogram *histogram, int v);
int hdr_c_countsIndex(HdrHistogram *histogram, int bucketIdx, int subBucketIdx);
int hdr_c_getBucketIndex(HdrHistogram *histogram, int v);
int hdr_c_getSubBucketIdx(HdrHistogram *histogram, int v, int idx);
bool _hdr_c_null(HdrHistogram *h);
int64 hdr_c_lowestEquivalentValue(HdrHistogram *h, int64 v);
int64 hdr_c_highestEquivalentValue(HdrHistogram *h, int64 v);
int64 hdr_c_sizeOfEquivalentValueRange(HdrHistogram *h, int64 v);
int64 hdr_c_nextNonEquivalentValue(HdrHistogram *h, int64 v);
int64 hdr_c_valueFromIndex(HdrHistogram *h, int32 bucketIdx, int32 subBucketIdx);
int64 hdr_c_getCountAtIndex(HdrHistogram *h, int32 bucketIdx, int32 subBucketIdx);
bool hdr_c_iterator_next(HdrHistogram *h, iterator *i);
HdrHistogram*  _hdr_c_recordValues(HdrHistogram *h, int32 v, int32 n);
HdrHistogram *_hdr_c_initialize(int32 min, int64 max, int32 sigfigs);
double _hdr_c_mean(HdrHistogram *h);
int64 _hdr_c_medianEquivalentValue(HdrHistogram *h, int32 v);
HdrHistogram* _hdr_c_merge(HdrHistogram *histogram, HdrHistogram *fromHistogram);

#define DatumGetHistogramP(X)         ((HdrHistogram *) PG_DETOAST_DATUM(X))
#define DatumGetHistogramPCopy(X)     ((HdrHistogram *) PG_DETOAST_DATUM_COPY(X))
#define HistogramPGetDatum(X)         PointerGetDatum(X)
#define PG_GETARG_HISTOGRAM_P(n)      DatumGetHistogramP(PG_GETARG_DATUM(n))
#define PG_GETARG_HISTOGRAM_P_COPY(n) DatumGetHistogramPCopy(PG_GETARG_DATUM(n))
#define PG_RETURN_HISTOGRAM_P(x)      return HistogramPGetDatum(x)

PG_FUNCTION_INFO_V1(hdr_histogram_in);
Datum
hdr_histogram_in(PG_FUNCTION_ARGS)
{
  char *str = PG_GETARG_CSTRING(0);

  int32 lowestTrackableValue;
  int32 highestTrackableValue;
  int32 unitMagnitude;
  int32 significantFigures;
  int32 subBucketHalfCountMagnitude;
  int32 subBucketHalfCount;
  int32 subBucketMask;
  int32 subBucketCount;
  int32 bucketCount;
  int32 countsLen;
  int32 totalCount;

  int32 countMin;
  int32 countMax;

  char countStr[strlen(str)];

  HdrHistogram *result;

  int retVal;

  retVal = sscanf(str, "(%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,\"[%d:%d]={%999[^}]}\")",
                        &lowestTrackableValue,
                        &highestTrackableValue,
                        &unitMagnitude,
                        &significantFigures,
                        &subBucketHalfCountMagnitude,
                        &subBucketHalfCount,
                        &subBucketMask,
                        &subBucketCount,
                        &bucketCount,
                        &countsLen,
                        &totalCount,
                        &countMin,
                        &countMax,
                        countStr);
  if (retVal != 14) {
      ereport(ERROR,
                (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                 errmsg("invalid input syntax for hdrHistogram: (%d) \"%s\" %d %d '%s'", retVal, str, countMin, countMax, countStr)));

  }

  int32 counts[countsLen];
  int i = 0;
  char *p = strtok (countStr,",");
  while (p!= NULL)
  {
    counts[i] = (int32)atoi(p);
    p = strtok (NULL, ",");
    i++;
  }

  result = (HdrHistogram *) palloc(sizeof(HdrHistogram) + (countsLen * sizeof(int32)));

  memcpy(result->counts, counts, countsLen * sizeof(int32));

  SET_VARSIZE(result, sizeof(HdrHistogram) + (countsLen * sizeof(int32)));

  result->lowestTrackableValue        = lowestTrackableValue;
  result->highestTrackableValue       = highestTrackableValue;
  result->unitMagnitude               = unitMagnitude;
  result->significantFigures          = significantFigures;
  result->subBucketHalfCountMagnitude = subBucketHalfCountMagnitude;
  result->subBucketHalfCount          = subBucketHalfCount;
  result->subBucketMask               = subBucketMask;
  result->subBucketCount              = subBucketCount;
  result->bucketCount                 = bucketCount;
  result->countsLen                   = countsLen;
  result->totalCount                  = totalCount;

  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(hdr_histogram_out);

Datum
hdr_histogram_out(PG_FUNCTION_ARGS)
{
    HdrHistogram *hist = (HdrHistogram *) PG_GETARG_POINTER(0);

    char *result;
    int32 len = 0;

    char *segment = psprintf("%d", hist->counts[0]);
    len += strlen(segment);
    for(int i = 1; i < hist->countsLen; i++)
    {
        segment = psprintf(",%d", hist->counts[i]);
        len += strlen(segment);
    }

    char countStr[len];
    memset(countStr,0,strlen(countStr));

    segment = psprintf("%d", hist->counts[0]);
    strcat(countStr, segment);
    for(int i = 1; i < hist->countsLen; i++)
    {
        segment = psprintf(",%d", hist->counts[i]);
        strcat(countStr, segment);
    }

    result = psprintf("(%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,\"[0:%d]={%s}\")", hist->lowestTrackableValue,
                                                                            hist->highestTrackableValue,
                                                                            hist->unitMagnitude,
                                                                            hist->significantFigures,
                                                                            hist->subBucketHalfCountMagnitude,
                                                                            hist->subBucketHalfCount,
                                                                            hist->subBucketMask,
                                                                            hist->subBucketCount,
                                                                            hist->bucketCount,
                                                                            hist->countsLen,
                                                                            hist->totalCount,
                                                                            hist->countsLen,
                                                                            countStr);
    PG_RETURN_CSTRING(result);
}

PG_FUNCTION_INFO_V1(hdr_histogram_recv);

Datum
hdr_histogram_recv(PG_FUNCTION_ARGS)
{
    StringInfo   buf = (StringInfo) PG_GETARG_POINTER(0);
    HdrHistogram *result;

    result = (HdrHistogram *) palloc(sizeof(HdrHistogram));
    result->lowestTrackableValue        = pq_getmsgint(buf, sizeof(int32));
    result->highestTrackableValue       = pq_getmsgint(buf, sizeof(int32));
    result->unitMagnitude               = pq_getmsgint(buf, sizeof(int32));
    result->significantFigures          = pq_getmsgint(buf, sizeof(int32));
    result->subBucketHalfCountMagnitude = pq_getmsgint(buf, sizeof(int32));
    result->subBucketHalfCount          = pq_getmsgint(buf, sizeof(int32));
    result->subBucketMask               = pq_getmsgint(buf, sizeof(int32));
    result->subBucketCount              = pq_getmsgint(buf, sizeof(int32));
    result->bucketCount                 = pq_getmsgint(buf, sizeof(int32));
    result->countsLen                   = pq_getmsgint(buf, sizeof(int32));
    result->totalCount                  = pq_getmsgint(buf, sizeof(int32));
    for(int i = 0; i < result->countsLen; i++)
      result->counts[i] = pq_getmsgint(buf, sizeof(int32));
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(hdr_histogram_send);

Datum
hdr_histogram_send(PG_FUNCTION_ARGS)
{
    HdrHistogram   *HdrHistogram = (struct HdrHistogram *) PG_GETARG_POINTER(0);
    StringInfoData buf;

    pq_begintypsend(&buf);
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->lowestTrackableValue, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->highestTrackableValue, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->unitMagnitude, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->significantFigures, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->subBucketHalfCountMagnitude, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->subBucketHalfCount, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->subBucketMask, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->subBucketCount, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->bucketCount, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->countsLen, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->totalCount, sizeof(int32));
    appendBinaryStringInfo(&buf, (char *) &HdrHistogram->counts, HdrHistogram->countsLen * sizeof(int32));
    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}


#ifdef PG_MODULE_MAGIC
  PG_MODULE_MAGIC;
#endif

int hdr_c_bitLen(int x) {
   int n = 0;

   while(x >= 32768)
   {
     x >>= 16;
     n += 16;
   }

   if(x >= 128)
   {
      x >>= 8;
      n += 8;
   }

   if(x >= 8)
   {
     x >>= 4;
     n += 4;
   }

   if(x >= 2)
   {
     x >>= 2;
     n += 2;
   }

   if(x >= 1)
   {
     n += 1;
   }

   return n;
}

int hdr_c_getSubBucketIdx(HdrHistogram *histogram, int v, int idx) {
   int subBucketIdx;

   subBucketIdx = (v >> (idx + histogram->unitMagnitude));

   return subBucketIdx;
}

int hdr_c_getBucketIndex(HdrHistogram *histogram, int v) {
  int idx;

  idx = (hdr_c_bitLen(v | histogram->subBucketMask) - histogram->unitMagnitude) - (histogram->subBucketHalfCountMagnitude + 1);

  return idx;
}

int hdr_c_countsIndex(HdrHistogram *histogram, int bucketIdx, int subBucketIdx) {
  return ((bucketIdx + 1) << histogram->subBucketHalfCountMagnitude) + (subBucketIdx - histogram->subBucketHalfCount);
}

int hdr_c_countsIndexFor(HdrHistogram *histogram, int v) {
  int bucketIdx;
  int subBucketIdx;

  bucketIdx = hdr_c_getBucketIndex(histogram, v);
  subBucketIdx = hdr_c_getSubBucketIdx(histogram, v, bucketIdx);

  return hdr_c_countsIndex(histogram, bucketIdx, subBucketIdx);
}

Datum hdr_c_totalCount(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_totalCount);
Datum hdr_c_totalCount(PG_FUNCTION_ARGS) {
  HdrHistogram *histogram = (HdrHistogram *) PG_GETARG_POINTER(0);

  PG_RETURN_INT32(histogram->totalCount);
}

bool _hdr_c_null(HdrHistogram *h)
{
  if(h == NULL)
    return true;
  else
    return false;
}

Datum hdr_c_null(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_null);
Datum hdr_c_null(PG_FUNCTION_ARGS) {
  HdrHistogram *histogram = (HdrHistogram *) PG_GETARG_POINTER(0);
  PG_RETURN_BOOL( _hdr_c_null(histogram));
}

Datum hdr_c_initialize(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_initialize);
Datum hdr_c_initialize(PG_FUNCTION_ARGS) {
  int32 min = PG_GETARG_INT32(0);
  int64 max = PG_GETARG_INT64(1);
  int32 sigfigs = PG_GETARG_INT32(2);

  HdrHistogram *h = _hdr_c_initialize(min, max, sigfigs);

  SET_VARSIZE(h, sizeof(HdrHistogram) + (h->countsLen * sizeof(int32)));

  PG_RETURN_POINTER(h);
}

HdrHistogram* _hdr_c_initialize(int32 min, int64 max, int32 sigfigs) {
  int32 unitMagnitude;

  if(sigfigs < 1 || 5 < sigfigs) {
    ereport(ERROR,
              (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
               errmsg("significantFigures must be [1,5] (was %d)", sigfigs)));
  }

  int32 largestValueWithSingleUnitResolution = 2 * pow(10, sigfigs);
  int32 subBucketCountMagnitude = (int32) ceil(log((double)largestValueWithSingleUnitResolution) / log(2));
  int32 subBucketHalfCountMagnitude = ((subBucketCountMagnitude > 1) ? subBucketCountMagnitude : 1) - 1;

  if(min > 0) {
    unitMagnitude = (int32) floor(log((double)min) / log(2));
  }
  else {
    unitMagnitude = 0;
  }

  if(unitMagnitude < 0) {
    unitMagnitude = 0;
  }

  int32 subBucketCount = (int32) pow(2, (subBucketHalfCountMagnitude + 1));
  int32 subBucketHalfCount = subBucketCount / 2;
  int32 subBucketMask = ((int64) (subBucketCount - 1) << unitMagnitude);
  int64 smallestUntrackableValue = (int64) subBucketCount << unitMagnitude;
  int32 bucketsNeeded = 1;

  while(smallestUntrackableValue <= max) {
    if(smallestUntrackableValue > INT64_MAX / 2) {
      bucketsNeeded++;
      break;
    }
    smallestUntrackableValue <<= 1;
    bucketsNeeded++;
  }

  int32 bucketCount = bucketsNeeded;
  int32 countsLen = (bucketCount + 1) * (subBucketCount / 2);
  int32 totalCount = 0;
  int32 counts[countsLen];

  for(int i = 0; i < countsLen; i++) {
    counts[i] = 0;
  }

  HdrHistogram *hist = (HdrHistogram *) palloc(sizeof(HdrHistogram) + (countsLen * sizeof(int32)));
  memcpy(hist->counts, counts, countsLen * sizeof(int32));

  hist->lowestTrackableValue = min;
  hist->highestTrackableValue = max;
  hist->significantFigures = sigfigs;
  hist->subBucketHalfCountMagnitude = subBucketHalfCountMagnitude;
  hist->subBucketHalfCount = subBucketHalfCount;
  hist->unitMagnitude = unitMagnitude;
  hist->subBucketMask = subBucketMask;
  hist->subBucketCount = subBucketCount;
  hist->totalCount = totalCount;
  hist->bucketCount = bucketCount;
  hist->countsLen = countsLen;

  return hist;
}

Datum hdr_c_mean(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_mean);
Datum
hdr_c_mean(PG_FUNCTION_ARGS) {
  HdrHistogram *h = (HdrHistogram *) PG_GETARG_POINTER(0);

  double mean = _hdr_c_mean(h);

  PG_RETURN_FLOAT8(mean);
}

double _hdr_c_mean(HdrHistogram *h) {
  double total;

  if(h->totalCount == 0)
    return 0;

  total = 0;

  iterator i;
  i.bucketIdx = 0;
  i.subBucketIdx = -1;
  i.countAtIdx = 0;
  i.countToIdx = 0;
  i.valueFromIdx = 0;
  i.bucketIdx = 0;
  i.highestEquivalentValue = 0;

  while(hdr_c_iterator_next(h, &i)) {
    if(i.countAtIdx != 0) {
      total += (i.countAtIdx * _hdr_c_medianEquivalentValue(h, i.valueFromIdx));
    }
  }

  return (double)(total / h->totalCount);
}

Datum hdr_c_stdDev(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_stdDev);
Datum hdr_c_stdDev(PG_FUNCTION_ARGS) {
  HdrHistogram *h = (HdrHistogram *) PG_GETARG_POINTER(0);

  if(h->totalCount == 0)
    return 0;

  double mean;
  double dev;
  double geometricDevTotal;

  mean = _hdr_c_mean(h);
  geometricDevTotal = 0.0;

  iterator i;
  i.bucketIdx = 0;
  i.subBucketIdx = -1;
  i.countAtIdx = 0;
  i.countToIdx = 0;
  i.valueFromIdx = 0;
  i.bucketIdx = 0;
  i.highestEquivalentValue = 0;

  while(hdr_c_iterator_next(h, &i)) {
    if(i.countAtIdx != 0) {
      dev = _hdr_c_medianEquivalentValue(h, i.valueFromIdx) - mean;
      geometricDevTotal += (dev * dev) * i.countAtIdx;
    }
  }

  double value = geometricDevTotal / h->totalCount;
  double retVal = 0;
  if(value > 0)
    retVal = sqrt(value);

  PG_RETURN_FLOAT8(retVal);
}

Datum hdr_c_max(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_max);
Datum hdr_c_max(PG_FUNCTION_ARGS) {
  HdrHistogram *histogram = (HdrHistogram *) PG_GETARG_POINTER(0);
  int32 max = 0;

  iterator i;
  i.bucketIdx = 0;
  i.subBucketIdx = -1;
  i.countAtIdx = 0;
  i.countToIdx = 0;
  i.valueFromIdx = 0;
  i.bucketIdx = 0;
  i.highestEquivalentValue = 0;

  while(hdr_c_iterator_next(histogram, &i)) {
    if(i.countAtIdx != 0) {
      max = i.highestEquivalentValue;
    }
  }

  PG_RETURN_INT64(hdr_c_highestEquivalentValue(histogram, max));
}

Datum hdr_c_min(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_min);
Datum hdr_c_min(PG_FUNCTION_ARGS) {
  HdrHistogram *histogram = (HdrHistogram *) PG_GETARG_POINTER(0);
  int32 min = 0;

  iterator i;
  i.bucketIdx = 0;
  i.subBucketIdx = -1;
  i.countAtIdx = 0;
  i.countToIdx = 0;
  i.valueFromIdx = 0;
  i.bucketIdx = 0;
  i.highestEquivalentValue = 0;

  while(hdr_c_iterator_next(histogram, &i)) {
    if(i.countAtIdx != 0 && min == 0) {
      min = i.highestEquivalentValue;
      break;
    }
  }

  PG_RETURN_INT64(hdr_c_lowestEquivalentValue(histogram, min));
}



Datum hdr_c_valueAtQuantile(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_valueAtQuantile);
Datum hdr_c_valueAtQuantile(PG_FUNCTION_ARGS) {
  HdrHistogram *histogram = (HdrHistogram *) PG_GETARG_POINTER(0);
  double q = PG_GETARG_FLOAT8(1);

  if(q > 100) {
    q = 100;
  }

  int32 total = 0;
  double countAtPercentile = (((q / 100.0) * histogram->totalCount) + 0.5);

  iterator i;
  i.bucketIdx = 0;
  i.subBucketIdx = -1;
  i.countAtIdx = 0;
  i.countToIdx = 0;
  i.valueFromIdx = 0;
  i.bucketIdx = 0;
  i.highestEquivalentValue = 0;

  while(hdr_c_iterator_next(histogram, &i)) {
    total += i.countAtIdx;

    if(total >= countAtPercentile) {
      PG_RETURN_FLOAT8(hdr_c_highestEquivalentValue(histogram, i.valueFromIdx));
    }
  }

  PG_RETURN_FLOAT8(0);
}


Datum hdr_c_distribution(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_distribution);
Datum hdr_c_distribution(PG_FUNCTION_ARGS) {
  HdrHistogram *histogram = (HdrHistogram *) PG_GETARG_POINTER(0);

  iterator i;
  i.bucketIdx = 0;
  i.subBucketIdx = -1;
  i.countAtIdx = 0;
  i.countToIdx = 0;
  i.valueFromIdx = 0;
  i.bucketIdx = 0;
  i.highestEquivalentValue = 0;

  ArrayType *result;
  Datum *data = palloc(sizeof(Datum) * 3 * histogram->countsLen);
  int32 *dims = palloc(sizeof(int32) * 2);
  int32 *lbs = palloc(sizeof(int32) * 2);

  int32 index = 0;
  int32 count = 0;

  while(hdr_c_iterator_next(histogram, &i)) {
    data[index++] = hdr_c_lowestEquivalentValue(histogram, i.valueFromIdx);
    data[index++] = i.highestEquivalentValue;
    data[index++] = i.countAtIdx;
    count++;
  }

  dims[0] = count;
  dims[1] = 3;

  lbs[0] = 1;
  lbs[1] = 1;

  result = construct_md_array(data, NULL, 2, dims, lbs, INT8OID, sizeof(data), true, 'd');

  PG_RETURN_ARRAYTYPE_P(result);
}


int64 hdr_c_highestEquivalentValue(HdrHistogram *h, int64 v) {
  return hdr_c_nextNonEquivalentValue(h, v) - 1;
}

int64 hdr_c_nextNonEquivalentValue(HdrHistogram *h, int64 v) {
	return hdr_c_lowestEquivalentValue(h, v) + hdr_c_sizeOfEquivalentValueRange(h, v);
}

int64 hdr_c_valueFromIndex(HdrHistogram *h, int32 bucketIdx, int32 subBucketIdx) {
	return (int64)subBucketIdx << (uint)((int64)bucketIdx + h->unitMagnitude);
}

int64 hdr_c_getCountAtIndex(HdrHistogram *h, int32 bucketIdx, int32 subBucketIdx) {
	return h->counts[hdr_c_countsIndex(h, bucketIdx, subBucketIdx)];
}

int64 _hdr_c_medianEquivalentValue(HdrHistogram *h, int32 v) {
	return hdr_c_lowestEquivalentValue(h, v) + (hdr_c_sizeOfEquivalentValueRange(h, v) >> 1);
}

int64 hdr_c_sizeOfEquivalentValueRange(HdrHistogram *h, int64 v) {
	int64 bucketIdx = hdr_c_getBucketIndex(h, v);
	int64 subBucketIdx = hdr_c_getSubBucketIdx(h, v, bucketIdx);
	int64 adjustedBucket = bucketIdx;

  if(subBucketIdx >= h->subBucketCount) {
		adjustedBucket++;
	}
	return (int64)1 << ((uint)h->unitMagnitude + (int64)adjustedBucket);
}

int64 hdr_c_lowestEquivalentValue(HdrHistogram *h, int64 v) {
	int64 bucketIdx = hdr_c_getBucketIndex(h, v);
	int64 subBucketIdx = hdr_c_getSubBucketIdx(h, v, bucketIdx);
	return hdr_c_valueFromIndex(h, bucketIdx, subBucketIdx);
}

bool hdr_c_iterator_next(HdrHistogram *h, iterator *i) {
  if(i->countToIdx >= h->totalCount) {
		return false;
	}

	i->subBucketIdx++;
	if(i->subBucketIdx >= h->subBucketCount) {
		i->subBucketIdx = h->subBucketHalfCount;
		i->bucketIdx++;
	}

	if(i->bucketIdx >= h->bucketCount) {
		return false;
	}

	i->countAtIdx = hdr_c_getCountAtIndex(h, i->bucketIdx, i->subBucketIdx);
	i->countToIdx += i->countAtIdx;
	i->valueFromIdx = hdr_c_valueFromIndex(h, i->bucketIdx, i->subBucketIdx);
	i->highestEquivalentValue = hdr_c_highestEquivalentValue(h, i->valueFromIdx);

	return true;
}


Datum hdr_c_recordValue(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_recordValue);
Datum
hdr_c_recordValue(PG_FUNCTION_ARGS) {
  HdrHistogram *histogram = (HdrHistogram *) PG_GETARG_POINTER(0);
  int32 v = PG_GETARG_INT32(1);

  _hdr_c_recordValues(histogram, v, 1);

  PG_RETURN_POINTER(histogram);
}

Datum hdr_c_recordValues(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_recordValues);
Datum
hdr_c_recordValues(PG_FUNCTION_ARGS) {
  HdrHistogram *histogram = (HdrHistogram *) PG_GETARG_POINTER(0);
  int32 v = PG_GETARG_INT32(1);
  int32 n = PG_GETARG_INT32(1);

  histogram = _hdr_c_recordValues(histogram, v, n);

  PG_RETURN_POINTER(histogram);
}

HdrHistogram* _hdr_c_recordValues(HdrHistogram *histogram, int32 v, int32 n) {
  int32 idx;

  idx = hdr_c_countsIndexFor(histogram, v);

  if(idx < 0 || histogram->countsLen <= idx)
  {
    return histogram;
  }

  histogram->counts[idx] += n;
  histogram->totalCount += n;

  return histogram;
}


Datum hdr_c_merge(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_merge);
Datum
hdr_c_merge(PG_FUNCTION_ARGS) {
  HdrHistogram *histogram = (HdrHistogram *) PG_GETARG_POINTER(0);
  HdrHistogram *fromHistogram = (HdrHistogram *) PG_GETARG_POINTER(1);

  PG_RETURN_POINTER(_hdr_c_merge(histogram, fromHistogram));
}

HdrHistogram* _hdr_c_merge(HdrHistogram *histogram, HdrHistogram *fromHistogram) {
  if(_hdr_c_null(histogram)) {
    histogram = _hdr_c_initialize(0, 60000, 1);
    SET_VARSIZE(histogram, sizeof(HdrHistogram) + (histogram->countsLen * sizeof(int32)));
  }

  iterator i;
  i.bucketIdx = 0;
  i.subBucketIdx = -1;
  i.countAtIdx = 0;
  i.countToIdx = 0;
  i.valueFromIdx = 0;
  i.bucketIdx = 0;
  i.highestEquivalentValue = 0;

  int64 v;
  int64 c;

  while(hdr_c_iterator_next(fromHistogram, &i)) {
    v = i.valueFromIdx;
    c = i.countAtIdx;

    _hdr_c_recordValues(histogram, v, c);
  }

  return histogram;
}

Datum hdr_c_group_accum(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_group_accum);
Datum
hdr_c_group_accum(PG_FUNCTION_ARGS) {
  HdrHistogram *one = (HdrHistogram *) PG_GETARG_POINTER(0);
  HdrHistogram *two = (HdrHistogram *) PG_GETARG_POINTER(1);

  PG_RETURN_POINTER(_hdr_c_merge(one, two));
}

Datum hdr_c_group_final(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_group_final);
Datum
hdr_c_group_final(PG_FUNCTION_ARGS) {
  HdrHistogram *one = (HdrHistogram *) PG_GETARG_POINTER(0);

  PG_RETURN_POINTER(one);
}


Datum hdr_c_cast_to_hdr(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(hdr_c_cast_to_hdr);
Datum
hdr_c_cast_to_hdr(PG_FUNCTION_ARGS) {
  Jsonb *jba = (Jsonb *) PG_GETARG_JSONB(0);
	char *jba_str = JsonbToCString(NULL, &jba->root, VARSIZE(jba));
  int32 min;
  int32 max;
  int32 sigfigs;
  char countStr[2048];
  memset(countStr,0,strlen(countStr));

  int retVal;

  retVal = sscanf(jba_str, "[%d , %d , %d , [%9999[^]]]",
                           &min,
                           &max,
                           &sigfigs,
                           countStr);
  if (retVal != 4) {
      ereport(ERROR,
                (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                 errmsg("invalid input syntax for hdrHistogram: (%d) %d %d %d '%s'", retVal, min, max, sigfigs, countStr)));

  }

  HdrHistogram *hist = _hdr_c_initialize(min, max, sigfigs);

  int32 counts[hist->countsLen];
  int i = 0;
  char *p = strtok (countStr,",");
  while (p!= NULL)
  {
    counts[i] = (int32)atoi(p);
    p = strtok (NULL, ",");
    i++;
  }
  memcpy(hist->counts, counts, hist->countsLen * sizeof(int32));

  int64 totalCount = 0;
	for(int i = 0; i < hist->countsLen; i++) {
		if(hist->counts[i] > 0) {
			totalCount += hist->counts[i];
		}
	}
	hist->totalCount = totalCount;

  SET_VARSIZE(hist, sizeof(HdrHistogram) + (hist->countsLen * sizeof(int32)));

  PG_RETURN_POINTER(hist);
}
