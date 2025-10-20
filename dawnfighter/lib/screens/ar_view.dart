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
  int health = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR View')),
      body: Stack(
        children: [
          ARView(
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            onARViewCreated: createARView,
          ),
          // Health bar at top center
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Health: $health',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Health bar background
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: health / 100,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            health > 50
                                ? Colors.green
                                : health > 25
                                ? Colors.orange
                                : Colors.red,
                          ),
                          minHeight: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Centered button at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  hit();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('HIT!'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  hit() {
    setState(() {
      health -= 10;
      if (health < 0) {
        health = 0; // Prevent negative health
      }
    });
    print("Health reduced to: $health");
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
      handleTaps: false,
      showAnimatedGuide: true,
    );

    objectManager!.onInitialize();

    sessionManager!.onPlaneDetected = onPlaneDetectedSpawnObject;

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
          0.0,
        ), // Identity rotation - stands upright
      );

      bool? didAddNode = await objectManager!.addNode(
        newNode,
        planeAnchor: newAnchor,
      );

      if (didAddNode == true) {
        allObjects.add(newNode);
        debugPrint("✅ Model placed automatically at fixed position");

        // Hide plane visualization after successful spawn
        // Re-initialize session with planes hidden
        sessionManager!.onInitialize(
          showFeaturePoints: false,
          handlePans: true,
          showPlanes: false, // Hide planes after spawning
          showWorldOrigin: false,
          handleTaps: false,
          showAnimatedGuide: false, // Hide hand animation after spawning
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
