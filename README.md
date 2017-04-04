# fillmissingrgb
Function for filling gaps (missing values) in RGB images. Works with Matlab 2016b or newer.

The function calls fillmissing() builtin Matlab function for doing the actual interpolation along both image axes. Works best if the known pixel values are distributed reasonably uniformly across the image being interpolated.
