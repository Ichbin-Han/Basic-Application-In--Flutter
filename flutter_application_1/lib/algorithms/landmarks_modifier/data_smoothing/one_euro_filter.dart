import 'dart:math';

class OneEuroFilter {
  //Controls the smoothness/noise reduction (f_min)
  final double minCutoff; 
  
  //the speed/lag adjustment (β).
  final double beta;      
  
  // Fixed cutoff frequency for derivative (speed) smoothing (dCutoff).
  final double _dCutoff = 1.0; 
  
  /// The previous filtered position value
  double _xPrev = 0.0;
  /// The previous smoothed derivative/speed value
  double _dxPrev = 0.0;
  /// The timestamp of the previous sample 
  double _tPrev = 0.0;

  OneEuroFilter({required this.minCutoff, required this.beta});

  // Getter codes for FLUC_ALERT calculation.
  double getPrevX() => _xPrev;
  double getPrevT() => _tPrev;
  double getPrevY() => _xPrev; 
  double getPrevZ() => _xPrev; 

  /// Calculates the alpha (smoothing factor).
  double _getAlpha(double cutoff, double T) {
    double r = 2.0 * pi * cutoff * T;
    return r / (r + 1.0);
  }

  /// Calculates the Low Pass Filter.
  double _smooth(double alpha, double x, double xPrev) {
    return alpha * x + (1.0 - alpha) * xPrev;
  }

  /// Main filtering method. Takes the raw coordinate (x) and its timestamp (t).
  /// Returns the smoothed coordinate.
  double filter(double x, double t) {
    
    // If this is the first call, initialize internal state with the raw input 
    // and return the raw value, skipping the smoothing process.
    if (_tPrev == 0.0) {
        _xPrev = x;
        _dxPrev = 0.0;
        _tPrev = t;
        return x; 
    }
    
    // Calculation of time stamp
    double T = t - _tPrev; 

    // Calculation of speed and smoothing
    double dx = (x - _xPrev) / T;
    double alphaDx = _getAlpha(_dCutoff, T);
    double dxSmooth = _smooth(alphaDx, dx, _dxPrev);
    
    // Calculation of CuttOff
    double cutoff = minCutoff + beta * dxSmooth.abs(); 
    
    // Calculation of the new Alpha value and smoothing the coordinate
    double alpha = _getAlpha(cutoff, T);
    double xSmooth = _smooth(alpha, x, _xPrev);

    // Update
    _xPrev = xSmooth;
    _dxPrev = dxSmooth;
    _tPrev = t;

    return xSmooth;
  }
}