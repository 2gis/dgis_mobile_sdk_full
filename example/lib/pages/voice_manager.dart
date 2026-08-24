import 'dart:async';

import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;
import 'package:flutter/material.dart';

import 'common.dart';

class VoiceManagerPage extends StatefulWidget {
  const VoiceManagerPage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<VoiceManagerPage> createState() => _VoiceManagerPageState();
}

class _VoiceManagerPageState extends State<VoiceManagerPage> {
  final formKey = GlobalKey<FormState>();
  late sdk.SearchManager searchManager;
  late sdk.VoiceManager voiceManager;
  late sdk.LocationService locationService;
  StreamSubscription<int>? progressSubscription;

  List<sdk.Voice> voices = [];
  List<sdk.Voice> filteredVoices = [];
  Map<String, double> progressMap = {};
  String filter = '';
  final TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    progressSubscription?.cancel();
    filterController.dispose();
    super.dispose();
  }

  void updateFilter(String value) {
    setState(() {
      filter = value;
      filteredVoices = voices.where((voice) {
        return voice.info.name.toLowerCase().contains(filter.toLowerCase());
      }).toList();
    });
  }

  void clearFilter() {
    filterController.clear();
    updateFilter('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredVoices.length,
              itemBuilder: (context, index) {
                final voice = filteredVoices[index];
                final progress = progressMap[voice.info.name] ?? 0.0;

                return ListTile(
                  title: Text(voice.info.name),
                  subtitle: Text(
                    progress > 0 && progress < 100
                        ? 'Installing: ${progress.toInt()}%'
                        : voice.info.preinstalled
                            ? 'Preinstalled'
                            : voice.info.installed
                                ? 'Installed'
                                : 'Not installed',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: voice.playWelcome,
                      ),
                      if (!voice.info.installed && progress == 0.0)
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            setState(() {
                              progressMap[voice.info.name] = 1.0;
                            });
                            voice.install();
                            progressSubscription =
                                voice.progressChannel.listen((progress) {
                              if (mounted) {
                                setState(() {
                                  progressMap[voice.info.name] =
                                      progress.toDouble();
                                });
                              }

                              if (progress == 100 && mounted) {
                                setState(() {
                                  progressMap.remove(voice.info.name);
                                });
                              }
                            });
                          },
                        ),
                      if (progress > 0.0 && progress < 100.0)
                        SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            value: progress / 100,
                          ),
                        ),
                      if (voice.info.installed && !voice.info.preinstalled)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            voice.uninstall();
                            if (mounted) {
                              setState(() {
                                progressMap.remove(voice.info.name);
                              });
                            }
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initialize() async {
    final context = AppContainer().initializeSdk();
    voiceManager = sdk.VoiceManager.instance(context);

    voiceManager.voicesChannel.listen((voicesList) {
      setState(() {
        voices = List.from(voicesList);
        filteredVoices = voices;
        voices.sort((a, b) {
          if (a.info.installed && !b.info.installed) {
            return -1;
          } else if (!a.info.installed && b.info.installed) {
            return 1;
          } else {
            return a.info.name.compareTo(b.info.name);
          }
        });
      });
    });
  }
}
