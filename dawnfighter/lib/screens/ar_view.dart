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
import '../models.dart';

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
  int health = 50;

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
          // Health bar at top center
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            left: 20,
            right: 20,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    healthBars[(health / 10).ceil()],
                    width: 500,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    'Health: $health',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Success overlay
          if (showSuccess)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Successfully Slayed\nthe Monster!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Return to Menu',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void hit() {
    setState(() {
      health -= 1;
      if (health < 0) {
        health = 0; // Prevent negative health
      }
      if (health == 0) {
        showSuccess = true;
      }
    });
  }

  Future<void> removeAllObjects() async {
    allAnchors.forEach((model) {
      anchorManager!.removeAnchor(model);
    });
    allAnchors = [];
  }

  void dispose() {
    super.dispose();
    sessionManager!.dispose();
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

  void onPlaneDetectedSpawnObject(int planeCount) async {
    if (hasSpawnedObject || planeCount == 0) {
      return; // Already spawned or no planes yet
    }

    debugPrint("🎯 Plane detected: $planeCount - attempting to spawn object");

    // Get the current camera pose to place object relative to view
    var cameraPose = await sessionManager!.getCameraPose();
    if (cameraPose == null) {
      debugPrint("⚠️ Camera pose not available yet");
      return;
    }

    hasSpawnedObject = true;

    // Extract position from camera pose but create upright orientation
    var cameraPosition = cameraPose.getTranslation();

    // Get camera's forward direction (Z-axis) from rotation matrix
    var cameraRotation = cameraPose.getRotation();
    var cameraForward = cameraRotation * vm.Vector3(0, 0, -1);

    // Calculate position in front of camera (project onto horizontal plane)
    var horizontalForward = vm.Vector3(
      cameraForward.x,
      0,
      cameraForward.z,
    ).normalized();
    var targetPosition = cameraPosition + (horizontalForward * 1.0);
    targetPosition.y =
        cameraPosition.y - 0.3; // Place slightly below camera height

    // Create transformation matrix with position only (no rotation)
    // This keeps the object upright relative to world coordinates
    var objectTransform = Matrix4.identity();
    objectTransform.setTranslation(targetPosition);

    // Create an anchor at this position
    var newAnchor = ARPlaneAnchor(transformation: objectTransform);
    bool? didAddAnchor = await anchorManager!.addAnchor(newAnchor);

    if (didAddAnchor == true) {
      allAnchors.add(newAnchor);
      debugPrint("✅ Anchor created at fixed position");

      // Add the model to the anchor
      var newNode = ARNode(
        type: NodeType.webGLB,
        uri: Models.supabaseBumling,
        scale: vm.Vector3(0.02, 0.02, 0.02),
        position: vm.Vector3.zero(), // Position relative to anchor
        rotation: vm.Vector4(
          1.0,
          0.0,
          0.0,
          1.5708,
        ), // Identity rotation - stands upright
      );

      bool? didAddNode = await objectManager!.addNode(
        newNode,
        planeAnchor: newAnchor,
      );

      if (didAddNode == true) {
        allObjects.add(newNode);
        // Hide plane visualization after successful spawn
        // Re-initialize session with planes hidden
        sessionManager!.onInitialize(
          showFeaturePoints: false,
          handlePans: true,
          showPlanes: false,
          showWorldOrigin: false,
          handleTaps: true,
          showAnimatedGuide: false,
        );
        debugPrint("🛑 Plane visualization hidden");
        debugPrint("🛑 Hand animation hidden");
      } else {
        sessionManager!.onError!("❌ Failed to add model to anchor");
        hasSpawnedObject = false; // Reset to try again
      }
    } else {
      sessionManager!.onError!("❌ Failed to add anchor");
      hasSpawnedObject = false; // Reset to try again
    }
  }
}
