import 'package:ar_flutter_plugin_updated/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_updated/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_updated/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_updated/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_updated/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'dart:async';
import 'dart:developer' as developer;
import 'package:light/light.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models.dart';
import '../widgets/successCard.dart';

class AppArView extends StatefulWidget {
  const AppArView({super.key});

  @override
  State<AppArView> createState() => _AppArViewState();
}

class _AppArViewState extends State<AppArView> {
  ARSessionManager? sessionManager;
  ARObjectManager? objectManager;
  ARAnchorManager? anchorManager;

  List<ARNode> allObjects = [];
  List<ARAnchor> allAnchors = [];
  bool hasSpawnedObject = false;
  bool showSuccess = false;
  bool tooDark = false;
  bool foundPlane = false;
  int health = 50;

  // Light sensor
  Light? _light;
  StreamSubscription? _lightSubscription;
  double DARK_THRESHOLD = 10.0;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<String> healthBars = [
    "assets/images/healthbar/empty_health_bar.png",
    "assets/images/healthbar/1..5_health_bar.png",
    "assets/images/healthbar/2..5_health_bar.png",
    "assets/images/healthbar/3..5_health_bar.png",
    "assets/images/healthbar/4..5_health_bar.png",
    "assets/images/healthbar/full_health_bar.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ARView(
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            onARViewCreated: createARView,
          ),
          // Too dark overlay
          if (tooDark)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.6,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/light.png',
                  width: 300,
                  height: 300,
                ),
              ),
            ),
          if (!tooDark && !foundPlane && !hasSpawnedObject)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.6,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/lookaround.png',
                  width: 300,
                  height: 300,
                ),
              ),
            ),
          if (!tooDark && foundPlane && hasSpawnedObject && !showSuccess) ...[
            // Health bar at top center
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  child: Image.asset(
                    healthBars[(health / 10).ceil()],
                    width: 500,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Bumling appeared overlay
            Positioned(
              top: MediaQuery.of(context).size.height * 0.6,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/bumlingappeared.png',
                  width: 300,
                  height: 300,
                ),
              ),
            ),
          ],
          // Success overlay
          if (showSuccess)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [SuccessCard()],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> hit() async {
    setState(() {
      health -= 1;
      if (health < 0) {
        health = 0; // Prevent negative health
      }
      if (health == 0) {
        showSuccess = true;
        
      }
    });
    if (showSuccess) {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
    }
  }

  Future<void> removeAllObjects() async {
    allAnchors.forEach((model) {
      anchorManager!.removeAnchor(model);
    });
    allAnchors = [];
  }

  @override
  void initState() {
    super.initState();
    _initializeLightSensor();
    _playBackgroundMusic();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.play(AssetSource('audio/boss_battle_music.mp3'));

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      await _audioPlayer.setVolume(0.5);

    } catch (e) {
    }
  }

  Future<void> _initializeLightSensor() async {
    try {
      _light = Light();

      // Start listening to light sensor changes
      _lightSubscription = _light!.lightSensorStream.listen(
        (int luxValue) {
          setState(() {
            tooDark = luxValue < DARK_THRESHOLD;
          });
        },
        onError: (error) {
          //
        },
      );
    } catch (e) {
      //
    }
  }

  void createARView(
    ARSessionManager arsessionManager,
    ARObjectManager arobjectManager,
    ARAnchorManager aranchorManager,
    ARLocationManager arlocationManager,
  ) {
    sessionManager = arsessionManager;
    objectManager = arobjectManager;
    anchorManager = aranchorManager;

    sessionManager!.onInitialize(
      showFeaturePoints: false,
      handlePans: true,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: true,
      showAnimatedGuide: true,
    );

    objectManager!.onInitialize();

    sessionManager!.onPlaneDetected = onPlaneDetectedSpawnObject;

    objectManager!.onNodeTap = (tappedNodes) async {
      if (tappedNodes.isNotEmpty) {
        hit();
      }
    };

    objectManager!.onPanStart = duringOnPanStart;
    objectManager!.onPanChange = duringOnPanChange;
    objectManager!.onPanEnd = duringOnPanEnd;

    objectManager!.onRotationStart = duringOnRotationStart;
    objectManager!.onRotationChange = duringOnRotationChange;
    objectManager!.onRotationEnd = duringOnRotationEnd;
  }

  @override
  Future<void> dispose() async {
    _lightSubscription?.cancel();
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    sessionManager?.dispose();
    super.dispose();
  }

  void duringOnPanStart(String objectNodeName) {
    print("Started panning on $objectNodeName");
  }

  void duringOnPanChange(String objectNodeName) {
    print("Panning on $objectNodeName");
  }

  void duringOnPanEnd(String objectNodeName, Matrix4 transformMatrix4) {
    print("Ended panning on $objectNodeName");
    final panNode = allObjects.firstWhere(
      (object) => object.name == objectNodeName,
    );
  }

  void duringOnRotationStart(String objectNodeName) {
    print("Started rotating on $objectNodeName");
  }

  void duringOnRotationChange(String objectNodeName) {
    print("Rotating on $objectNodeName");
  }

  void duringOnRotationEnd(String objectNodeName, Matrix4 transformMatrix4) {
    print("Ended rotating on $objectNodeName");
    final rotationNode = allObjects.firstWhere(
      (object) => object.name == objectNodeName,
    );
  }

  void onPlaneDetectedSpawnObject(int planeCount) async {
    if (hasSpawnedObject || planeCount == 0) {
      return; // Already spawned or no planes yet
    }
    setState(() {
      foundPlane = true;
    });

    var cameraPose = await sessionManager!.getCameraPose();
    if (cameraPose == null) {
      return;
    }


    //Camera stuff etc
    var cameraPosition = cameraPose.getTranslation();

    var cameraRotation = cameraPose.getRotation();
    var cameraForward = cameraRotation * vm.Vector3(0, 0, -1);

    var horizontalForward = vm.Vector3(
      cameraForward.x,
      0,
      cameraForward.z,
    ).normalized();
    var targetPosition = cameraPosition + (horizontalForward * 1.0);
    targetPosition.y =
        cameraPosition.y - 0.3; // Place slightly below camera height

    var objectTransform = Matrix4.identity();
    objectTransform.setTranslation(targetPosition);

    var newAnchor = ARPlaneAnchor(transformation: objectTransform);
    bool? didAddAnchor = await anchorManager!.addAnchor(newAnchor);

    if (didAddAnchor == true) {
      allAnchors.add(newAnchor);

      var newNode = ARNode(
        type: NodeType.webGLB,
        uri: Models.supabaseBumling,
        scale: vm.Vector3(0.02, 0.02, 0.02),
        position: vm.Vector3.zero(), 
        rotation: vm.Vector4(
          1.0,
          0.0,
          0.0,
          1.5708,
        ), 
      );

      bool? didAddNode = await objectManager!.addNode(
        newNode,
        planeAnchor: newAnchor,
      );

      if (didAddNode == true) {
        setState(() {
          hasSpawnedObject = true;
        });
        allObjects.add(newNode);

        sessionManager!.onInitialize(
          showFeaturePoints: false,
          handlePans: true,
          showPlanes: false,
          showWorldOrigin: false,
          handleTaps: true,
          showAnimatedGuide: false,
        );
      } else {
        hasSpawnedObject = false;
      }
    } else {
      hasSpawnedObject = false; 
    }
  }
}
