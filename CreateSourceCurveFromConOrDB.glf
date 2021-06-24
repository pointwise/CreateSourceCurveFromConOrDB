#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

#######################################################################
##
## Convert connectors and curves to sources
##
## Allows you to choose connectors and curves and then convert those 
## entities in the selection to sources
##
## 1. Select either any connector or curve.
## 2. Initiate script
## 3. End result is a source entity in which the connector or curve 
##    has been directly converted into the new source.
##
#######################################################################

# Load Pointwise Glyph package
package require PWI_Glyph

## Procedures

# Select connectors and/or curves
proc selectConnectorsAndCurves { } {

  # Mask to select connectors and database curves
  set conMask [pw::Display createSelectionMask -requireDatabase [list Curves] \
    -requireConnector [list] -blockConnector "Pole"]
  pw::Display selectEntities \
      -description "Select the connectors and/or database curves to convert." \
      -selectionmask $conMask selection
  return [concat $selection(Connectors) $selection(Databases)]
}

# Convert connectors and database curves to source curves.
# The default size settings will be applied to the new source curves.
proc convertToSourceCurves { crvs } {
  foreach crv $crvs {
    set src [pw::SourceCurve create]
    $src setName "converted_[$crv getName]"
    foreach oseg [$crv getSegments] {
      set nseg [[$oseg getType] create]
      switch [$oseg getType] {
        pw::SegmentCircle {
          $nseg addPoint [$oseg getPoint 1]
          $nseg addPoint [$oseg getPoint 2]
          switch [$oseg getAlternatePointType] {
            Shoulder {
              $nseg setShoulderPoint [$oseg getShoulderPoint] [$oseg getNormal]
            }
            Center {
              $nseg setCenterPoint [$oseg getCenterPoint] [$oseg getNormal]
            }
            Angle {
              $nseg setAngle [$oseg getAngle] [$oseg getNormal]
            }
            EndAngle {
              $nseg setEndAngle [$oseg getAngle] [$oseg getNormal]
            }
          }
        }

        pw::SegmentConic {
          $nseg addPoint [$oseg getPoint 1]
          $nseg addPoint [$oseg getPoint 2]
          switch [$oseg getAlternatePointType] {
            Shoulder {
              $nseg setShoulderPoint [$oseg getShoulderPoint]
            }
            Intersect {
              $nseg setIntersectPoint [$oseg getIntersectPoint]
            }
          }
          $nseg setRho [$oseg getRho]
        }

        pw::SegmentSpline {
          set npts [$oseg getPointCount]
          for { set ipt 1 } { $ipt <= $npts } { incr ipt } {
            $nseg addPoint [$oseg getPoint $ipt]
          }
          $nseg setSlope [$oseg getSlope]
          if { [$oseg getSlope] eq "Free" } {
            for { set ipt 2 } { $ipt <= $npts } { incr ipt } {
              $nseg setSlopeIn $ipt [$oseg getSlopeIn $ipt]
            }
            for { set ipt 1 } { $ipt < $npts } { incr ipt } {
              $nseg setSlopeOut $ipt [$oseg getSlopeOut $ipt]
            }
          }
        }

        pw::SegmentSurfaceSpline {
          set npts [$oseg getPointCount]
          for { set ipt 1 } { $ipt <= $npts } { incr ipt } {
            $nseg addPoint [$oseg getPoint $ipt]
          }
          $nseg setSlope [$oseg getSlope]
          if { [$oseg getSlope] eq "Free" } {
            for { set ipt 2 } { $ipt <= $npts } { incr ipt } {
              $nseg setSlopeIn $ipt [$oseg getSlopeIn $ipt]
            }
            for { set ipt 1 } { $ipt < $npts } { incr ipt } {
              $nseg setSlopeOut $ipt [$oseg getSlopeOut $ipt]
            }
          }
        }
      }
      $src addSegment $nseg
    }
  }
}

# --------------------------------------------------------------------------
# Main script body

# Convert selected connectors/curves to source curves
convertToSourceCurves [selectConnectorsAndCurves]

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
