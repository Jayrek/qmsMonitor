import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qms_monitory/model/queue_model.dart';

import 'model/now_serving_model.dart';
import 'model/up_nex_model.dart';
import 'qms_service.dart';

void main() {
  runApp(const QmsMonitorApp());
}

class QmsMonitorApp extends StatelessWidget {
  const QmsMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QMS Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final player = AudioPlayer();
  late final Timer periodicTimer;
  QueueModel? _queueModel;
  int previousCall = 0;

  @override
  void initState() {
    super.initState();
    _initFetch();
    periodicTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final response = await QmsService.getQueue();
      setState(() => _queueModel = response);
      if (previousCall < int.parse(_queueModel!.newCall.toString())) {
        setState(
          () => previousCall = int.parse(_queueModel!.newCall.toString()),
        );
        _playLocalFile();
      }
    });
  }

  Future<void> _initFetch() async {
    final response = await QmsService.getQueue();
    _playLocalFile();
    setState(() {
      _queueModel = response;
      previousCall = int.parse(_queueModel!.newCall.toString());
    });
  }

  @override
  void dispose() {
    player.dispose();
    periodicTimer.cancel();
    super.dispose();
  }

  Future<void> _playLocalFile() async {
    await player.play(AssetSource('sounds.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7EFF9),
      body: Row(
        children: [
          Flexible(
            child: _buildNowServingWidget(_queueModel?.nowServing),
          ),
          Flexible(
            child: _buildUpNextWidget(_queueModel?.upNext),
          ),
        ],
      ),
    );
  }

  Widget _buildNowServingWidget(List<NowServing>? nowServingList) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'NOW SERVING',
            style: TextStyle(
              fontSize: 20,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NAME',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'WINDOW',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          nowServingList != null
              ? Expanded(
                  child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 0,
                          color: Colors.grey.withOpacity(0.2),
                        );
                      },
                      itemCount: nowServingList.length,
                      itemBuilder: (context, index) {
                        final nowServing = nowServingList[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            nowServing.visitor.toString(),
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          dense: true,
                          trailing: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              nowServing.window.toString(),
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                )
              : const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text('No data to display!'),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildUpNextWidget(List<UpNext>? upNextList) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UP NEXT',
            style: TextStyle(
              fontSize: 20,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildUpNextVisitorList(upNextList),
          Divider(
            color: Colors.grey.withOpacity(0.2),
          ),
          const DateTimeDisplay(),
        ],
      ),
    );
  }

  Widget _buildUpNextVisitorList(List<UpNext>? upNextList) {
    if (upNextList != null) {
      return Expanded(
        flex: 3,
        child: ListView.builder(
            itemCount: upNextList.length,
            itemBuilder: (context, index) {
              final upNext = upNextList[index];
              return Text(
                upNext.visitor.toString(),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
      );
    }
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 30),
        child: Text('No data to display!'),
      ),
    );
  }
}

class DateTimeDisplay extends StatelessWidget {
  const DateTimeDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: StreamBuilder<DateTime>(
        stream:
            Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final now = snapshot.data!;

            // Format date
            final dateFormat = DateFormat('EEEE, MM/dd/yyyy');
            final formattedDate = dateFormat.format(now);

            // Format time
            final timeFormat = DateFormat('hh:mm a');
            final formattedTime = timeFormat.format(now);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedDate.split(
                        ', ',
                      )[1],
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        '|',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      formattedDate
                          .split(
                            ', ',
                          )[0]
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedTime.substring(0, 5),
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      formattedTime.substring(6, 8),
                      style: const TextStyle(
                          fontSize: 30,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return const Center(
                child:
                    CircularProgressIndicator()); // Placeholder while waiting for data
          }
        },
      ),
    );
  }
}
