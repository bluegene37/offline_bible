package dev.genexis.offlinebible

import com.ryanheise.audioservice.AudioServiceActivity

// AudioServiceActivity (rather than FlutterActivity) so media button events and
// the playback foreground service are routed correctly while the app is in the
// background or the screen is locked.
class MainActivity : AudioServiceActivity()
