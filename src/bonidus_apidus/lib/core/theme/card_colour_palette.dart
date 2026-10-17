import 'package:flutter/material.dart';

/// Colours cards are allowed to use. Extracted brand colours get snapped to
/// the closest entry here instead of being used raw, so harsh or overly
/// bright brand colours (e.g. a neon yellow) never end up on a card.
class CardColourPalette {
  CardColourPalette._();

  static const List<Color> allowed = [
    Color(0xFF1A5F8A), // blue
    Color(0xFF2E86C1), // sky blue
    Color(0xFF355070), // indigo
    Color(0xFF2A9D8F), // teal
    Color(0xFF52796F), // green
    Color(0xFF6B8E23), // olive green
    Color(0xFFC9A227), // muted mustard (soft yellow)
    Color(0xFFD68C45), // amber / orange
    Color(0xFFC1666B), // coral / red
    Color(0xFFB56576), // rose
    Color(0xFF6D597A), // purple
    Color(0xFF7F5539), // brown
    Color(0xFF495867), // slate gray

    // Darker / mid-tone additions — white label text stays readable.
    Color(0xFF264653), // deep teal
    Color(0xFF1B4332), // forest green
    Color(0xFF283618), // dark olive
    Color(0xFF9D0208), // deep red
    Color(0xFF7209B7), // violet
    Color(0xFF3A0CA3), // deep indigo
    Color(0xFF14213D), // navy
    Color(0xFF5C4033), // chocolate brown
    Color(0xFF006D77), // dark cyan
    Color(0xFFAE2012), // brick red

    // Light / bright additions — these are light enough that the label
    // switches to the primary blue instead of white for readability.
    Color(0xFFFFD166), // sunflower yellow
    Color(0xFFFFADAD), // light pink
    Color(0xFFB9FBC0), // mint pastel
    Color(0xFFCAFFBF), // light green
    Color(0xFFA0C4FF), // periwinkle
    Color(0xFFFDFFB6), // pale cream yellow

    // Saturated "brand primary" tones — the vivid, high-chroma colours
    // Benelux and German company logos are commonly built around, so logo
    // extraction has something close to snap to instead of falling back
    // to a muted tone.
    Color(0xFFFF6200), // vivid orange (Dutch bank-style)
    Color(0xFF0000A4), // deep blue (Dutch e-commerce-style)
    Color(0xFF00A1DE), // cyan blue (Dutch airline / retail-style)
    Color(0xFFFFD200), // vivid yellow (Dutch supermarket-style)
    Color(0xFF008200), // vivid green (Dutch brewery-style)
    Color(0xFFE4002B), // vivid red (Belgian retail-style)
    Color(0xFF0057B8), // corporate blue (Belgian bank-style)
    Color(0xFFE20074), // vivid magenta (German telecom-style)
    Color(0xFF0018A8), // deep blue (German bank-style)
    Color(0xFF0066B1), // corporate blue (German automotive-style)
    Color(0xFF001E50), // navy (German automotive-style)
    Color(0xFF009999), // vivid teal (German industrial-style)
    Color(0xFF0FAAFF), // azure (German software-style)
    Color(0xFFFFCC00), // vivid yellow (German logistics-style)
    Color(0xFFD40511), // vivid red (German logistics-style)
    Color(0xFF0050AA), // corporate blue (German discounter-style)
    Color(0xFFF9BA00), // vivid yellow (German airline-style)
    Color(0xFF05164D), // navy (German airline-style)
  ];

  static Color nearestTo(Color input) {
    Color closest = allowed.first;
    double closestDistance = _distanceSquared(input, closest);

    for (final candidate in allowed.skip(1)) {
      final distance = _distanceSquared(input, candidate);
      if (distance < closestDistance) {
        closest = candidate;
        closestDistance = distance;
      }
    }

    return closest;
  }

  // "Redmean" weighted distance — closer to human colour perception than
  // plain RGB Euclidean distance. Squared (no sqrt) since only relative
  // ordering matters here.
  static double _distanceSquared(Color a, Color b) {
    final rMean = (a.r + b.r) * 0.5 * 255;
    final dr = (a.r - b.r) * 255;
    final dg = (a.g - b.g) * 255;
    final db = (a.b - b.b) * 255;

    return (2 + rMean / 256) * dr * dr +
        4 * dg * dg +
        (2 + (255 - rMean) / 256) * db * db;
  }
}