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
import 'package:vector_math/vector_math_64.dart';
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
        ],
      ),
    );
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
    var cameraForward = cameraRotation * Vector3(0, 0, -1);

    // Calculate position in front of camera (project onto horizontal plane)
    var horizontalForward = Vector3(
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
        scale: Vector3(0.02, 0.02, 0.02),
        position: Vector3.zero(), // Position relative to anchor
        rotation: Vector4(
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
