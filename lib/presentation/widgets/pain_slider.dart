import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PainSlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double>? onChanged;

  const PainSlider({
    Key? key,
    this.initialValue = 2.0,
    this.onChanged,
  }) : super(key: key);

  @override
  State<PainSlider> createState() => _PainSliderState();
}

class _PainSliderState extends State<PainSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 12,
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: AppTheme.backgroundColor,
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
              trackShape: const RoundedRectSliderTrackShape(),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
              activeTickMarkColor: Colors.white.withValues(alpha: 0.5),
              inactiveTickMarkColor: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
            child: Slider(
              value: _currentValue,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
                if (widget.onChanged != null) widget.onChanged!(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                8,
                (index) {
                  final stops = [1, 2, 3, 4, 5, 6, 7, 10];
                  return Text(
                    stops[index].toString(),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
