import 'package:linksoap/detergent/model.dart';
import 'package:linksoap/softener/model.dart';

/// Some softeners to get you started.
const List<Softener> storeboughtSofteners = [
  Softener(
    name: 'YouTube No Shorts',
    domain: r'youtube\.com',
    replacement: 'www.youtube.com',
  ),
  Softener(
      name: "Fix Twitter",
      domain: r'twitter|x\.com',
      replacement: 'fxtwitter.com'),
];

/// Some detergents to get you started.
const List<Detergent> storeboughtDetergents = [
  Detergent(
    name: 'Good Ol Reliable',
    domain: r'.*',
    rule: r'ref|utm|source|clickfrom|sku|spm|pf_rd|_ga',
  ),
  Detergent(
    name: 'Spotify',
    domain: r'open\.spotify\.com',
    rule: r'dd|si',
  ),
  Detergent(
    name: 'Twitter',
    domain: r'twitter|x|fxtwitter\.com',
    rule: r't|s',
  ),
];
