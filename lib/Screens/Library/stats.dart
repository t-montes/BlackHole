/*
 *  This file is part of BlackHole (https://github.com/Sangwan5688/BlackHole).
 * 
 * BlackHole is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BlackHole is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BlackHole.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2023, Ankit Sangwan
 */

import 'dart:async';
import 'dart:math';

import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  int songsPlayed;
  Map mostPlayed;
  LinearGradient cardBackgroundGradient = const LinearGradient(
    colors: [
      Colors.transparent,
      Colors.transparent
    ], // Define your two colors here
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  Color textColor = Colors.white; // Initial text color
  bool showHint = true; // To control when to show the hint
  Timer? hintTimer;

  _StatsState()
      : songsPlayed = Hive.box('stats').length,
        mostPlayed =
            Hive.box('stats').get('mostPlayed', defaultValue: {}) as Map;

  @override
  void initState() {
    super.initState();

    // Start a timer to hide the hint overlay after 3 seconds
    hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showHint = false;
        });
      }
    });
  }

  @override
  void dispose() {
    hintTimer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.stats),
          centerTitle: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onDoubleTap: () {
            _handleDoubleTap();
          },
          child: Stack(
            children: [
              GradientContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatCard(
                          context,
                          label: AppLocalizations.of(context)!.songsPlayed,
                          value: songsPlayed.toString(),
                        ),
                        const SizedBox(height: 20),
                        _buildStatCard(
                          context,
                          label: AppLocalizations.of(context)!.mostPlayedSong,
                          value: mostPlayed['title']?.toString() ?? 'Unknown',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showHint) _buildHintOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    setState(() {
      _changeCardBackgroundGradient();
      showHint = false; // Hide the hint after the first double-tap
    });
  }

  void _changeCardBackgroundGradient() {
    // Generate a random linear gradient between two colors
    cardBackgroundGradient = _generateRandomGradient();
    // Determine text color based on the background color's brightness
    textColor = cardBackgroundGradient.colors[0].computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  LinearGradient _generateRandomGradient() {
    // Generate two random colors
    final color1 = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    final color2 = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    // Create a linear gradient between the two colors
    return LinearGradient(
      colors: [color1, color2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildHintOverlay(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withOpacity(0.6), // Semi-transparent black overlay
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your hand animation or other guidance here
            Icon(
              Icons.touch_app,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 20),
            Text(
              'Try double tapping!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient:
              cardBackgroundGradient, // Apply the gradient to the container
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor, // Set the text color
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: textColor, // Set the text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
