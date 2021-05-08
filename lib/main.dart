import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterquizapp/quiz.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Quiz quiz;
  List<Results> results;

  Future<void> fetchQuestions() async {
    var url = "https://opentdb.com/api.php?amount=20";
    var res = await http.get(Uri.parse(url));
    var decRes = jsonDecode(res.body);
    quiz = Quiz.fromJson(decRes);
    results = quiz.results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
        child: FutureBuilder(
            future: fetchQuestions(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('Press Button to start');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return errorData(snapshot);
                  } else {
                    return questionsList();
                  }
                  return null;
              }
            }),
      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot) {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Error: Check your internet connection",
            ),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              onPressed: () {
                fetchQuestions();
                setState(() {});
              },
              child: Text('Try Again!'),
            ),
          ],
        ));
  }

  ListView questionsList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => Card(
        color: Colors.white,
        elevation: 0.0,
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  results[index].question,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilterChip(
                        label: Text(results[index].category),
                        onSelected: (b) {},
                        backgroundColor: Colors.grey[100],
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      FilterChip(
                        label: Text(results[index].difficulty),
                        onSelected: (b) {},
                        backgroundColor: Colors.grey[100],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: Text(results[index].type.startsWith('m') ? "M" : "B"),
          ),
          children: results[index].allAnswers.map((m) {
            return AnswerWidget(results, index, m);
          }).toList(),
        ),
      ),
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;

  AnswerWidget(this.results, this.index, this.m);
  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c = Colors.black;
  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          setState(() {
            if (widget.m == widget.results[widget.index].correctAnswer) {
              c = Colors.green;
            } else {
              c = Colors.red;
            }
          });
        },
        title: Text(widget.m,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.bold,
            )));
  }
}
