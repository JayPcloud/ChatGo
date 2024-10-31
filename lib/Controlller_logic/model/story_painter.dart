import 'dart:math';

import 'package:flutter/material.dart';

class StoryPainter extends CustomPainter {
  double thickness;
  double numberOfSegments;
  int whiteSegment;

  StoryPainter({
    required this.thickness,
    required this.numberOfSegments,
    required this.whiteSegment,
});

  @override
  void paint (Canvas canvas, Size size){
    // final paint = Paint()
    //     ..strokeCap = StrokeCap.round
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = thickness;

    final center = Offset(size.width/2, size.height/2);
    final radius = size.width / 2-10;

    if(numberOfSegments > 1){
      for (var i = 0; i< numberOfSegments; i++){
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            ((1.5 * pi) + i * ((2*pi)/numberOfSegments)),
            (((2*pi)/numberOfSegments)-(pi/12)),
            false,
            Paint()
              ..color = i<whiteSegment?Colors.white:Colors.deepPurple
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke
              ..strokeWidth = thickness);
      }
    }else{
      canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
          (1.5 * pi),
          (2 * pi),
          false,
          Paint()
            ..color = numberOfSegments==whiteSegment?Colors.white:Colors.deepPurple
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke
            ..strokeWidth = thickness);
    }


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)=> true;
}
