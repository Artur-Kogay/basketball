import 'package:basketball/game.dart';
import 'package:countries_flag/countries_flag.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            Stack(
              children: [
                Container(
                  height: 205,
                  color: Colors.black,
                  child: Center(
                    child: Image.asset(
                      'assets/images/person.png',
                      height: MediaQuery.of(context).size.height * 1,
                      fit: BoxFit.fitHeight  ,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Make 1000 throws", style:
                      TextStyle(color: Color(0xff00C7B1), fontSize: 25, fontWeight: FontWeight.w900),),
                      Padding(padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0)),
                      Text("And multiply the points by 2", style:
                      TextStyle(color: Color(0xff00C7B1), fontSize: 15, fontWeight: FontWeight.w400),),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(30, 33, 41, 1),
                border: Border(
                  top: BorderSide(width: 6, color: Colors.white),
                ),
              ),
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/star.png',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(4),
                    color: Color.fromRGBO(97, 154, 56, 1),
                    child: Text(
                      'Game',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),

            GameField(Flags.laos, "laos".toUpperCase(), "08:00"),
            GameField(Flags.cambodia, "cambodia".toUpperCase(), "10:15"),
            GameField(Flags.zimbabwe, "zimbabwe".toUpperCase(), "12:30"),
            GameField(Flags.serbia, "serbia".toUpperCase(), "13:05"),
            GameField(Flags.kazakhstan, "kazakhstan".toUpperCase(), "14:45"),
            GameField(Flags.madagascar, "madagascar".toUpperCase(), "16:25"),
            GameField(Flags.norway, "norway".toUpperCase(), "18:25"),
            GameField(Flags.zambia, "zambia".toUpperCase(), "19:30"),
            GameField(Flags.honduras, "honduras".toUpperCase(), "22:15"),
          ],
        ),
      ),
    );
  }
}

class GameField extends StatelessWidget {

  GameField(this.flag, this.country, this.time);

  final String flag;
  final String country;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          color: Color.fromRGBO(97, 154, 56, 0.1),
        ),
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Image.asset(
              'assets/images/star.png',
              width: 20,
              height: 20,
            ),
            SizedBox(width: 8),
            //Image.asset(
            //  'assets/images/flag.png',
            //  width: 30,
            //  height: 30,
            //),
            CountriesFlag(flag, height: 35,),
            SizedBox(width: 8),
            Text(
              country + ' GAME',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color.fromRGBO(235, 239, 245, 1)),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/star.png',
              width: 20,
              height: 20,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            Spacer(),

            OutlinedButton(
              onPressed: ()=>{
                Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MainGame(),
                    )
                )
              },
              style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  backgroundColor: Color(0xFFEFF5EA),
                  side: BorderSide(width: 0.25, style: BorderStyle.solid, color: Colors.grey)
              ),
              child: const Text('Play', style: TextStyle(fontSize: 15, color: Colors.black),),)
            // Container(
            //   width: 100,
            //   height: 40,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: Color.fromRGBO(241, 244, 248, 1),
            //     border: Border.all(color: Color.fromRGBO(235, 239, 245, 1)),
            //   ),
            //   child: Text(
            //     'Play',
            //     style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
            //   ),
            // ),
          ],
        ),
      ),
    ],);
  }
}
