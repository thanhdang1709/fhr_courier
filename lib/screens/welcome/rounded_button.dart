import 'package:flutter/material.dart';
class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;

  const RoundedButton({
    Key key,
    this.text,
    this.press,
    this.color = Colors.deepPurple,
    this.textColor = Colors.white, this.size,
  }) : super(key: key);

  final Size size;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlatButton(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            color: color,
            onPressed: press,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(text, style: TextStyle(color: textColor),)
              ],
            )
        ),
      ),
    );
  }
}