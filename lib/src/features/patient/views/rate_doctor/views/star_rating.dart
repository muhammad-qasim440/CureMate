
import 'package:flutter/material.dart';
class StarRating extends StatefulWidget {
  final double rating;
  final Function(double) onRatingChanged;

  const StarRating({super.key, required this.rating, required this.onRatingChanged});

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
              widget.onRatingChanged(_rating);
            });
          },
        );
      }),
    );
  }
}
