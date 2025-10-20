import 'package:ar_flutter_plugin_updated/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_updated/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_updated/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_updated/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_updated/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_updated/models/ar_hittest_result.dart';
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

    sessionManager!.onPlaneOrPointTap = detectPlaneAndUserTap;
    sessionManager!.onPlaneDetected = (int planeCount) {
      planeDetected(planeCount);
    };

    objectManager!.onPanStart = duringOnPanStart;
    objectManager!.onPanChange = duringOnPanChange;
    objectManager!.onPanEnd = duringOnPanEnd;

    objectManager!.onRotationStart = duringOnRotationStart;
    objectManager!.onRotationChange = duringOnRotationChange;
    objectManager!.onRotationEnd = duringOnRotationEnd;
  }

  void planeDetected(int planeCount) async {
    debugPrint("Plane detected: $planeCount");

    if (!hasSpawnedObject && planeCount > 0) {
      hasSpawnedObject = true;

      // Create an anchor about 0.5 meters in front of the camera
      final cameraPose = await sessionManager!.getCameraPose();
      if (cameraPose == null) {
        debugPrint("⚠️ No camera pose available yet.");
        return;
      }

      // Translate the camera forward a bit
      final Matrix4 cameraTransform = cameraPose;
      final Vector3 forward = Vector3(0, 0, -0.5); // 0.5m in front
      final Vector3 translation = Vector3.zero()..add(forward);
      cameraTransform.translate(translation.x, translation.y, translation.z);

      // Create a manual anchor
      final anchor = ARPlaneAnchor(transformation: cameraTransform);
      bool? didAddAnchor = await anchorManager!.addAnchor(anchor);
      if (didAddAnchor == true) {
        allAnchors.add(anchor);
        debugPrint("✅ Anchor created in front of camera");

        // Add the model to the new anchor
        final node = ARNode(
          type: NodeType.webGLB,
          uri: Models.supabaseBaguette,
          scale: Vector3(0.62, 0.62, 0.62),
          position: Vector3.zero(),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0),
        );

        bool? didAddNode = await objectManager!.addNode(
          node,
          planeAnchor: anchor,
        );

        if (didAddNode == true) {
          allObjects.add(node);
          debugPrint("✅ Model placed automatically");
        } else {
          sessionManager!.onError!("❌ Failed to add model to anchor");
        }
      } else {
        sessionManager!.onError!("❌ Failed to add anchor");
      }
    }
  }

  Future<void> detectPlaneAndUserTap(List<ARHitTestResult> hitResults) async {
    var tapResults = hitResults.firstWhere(
      (ARHitTestResult hitpoint) => hitpoint.type == ARHitTestResultType.plane,
    );
    if (tapResults != null) {
      var planeARAnchor = ARPlaneAnchor(
        transformation: tapResults.worldTransform,
      );
      bool? didAddAnchor = await anchorManager!.addAnchor(planeARAnchor);
      if (didAddAnchor == true) {
        allAnchors.add(planeARAnchor);
        var newNode = ARNode(
          type: NodeType.webGLB,
          uri: Models.supabaseBaguette,
          scale: Vector3(0.62, 0.62, 0.62),
          position: Vector3(0.0, 0.0, 0.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0),
        );

        bool? didAddNodeToAnchor = await objectManager!.addNode(
          newNode,
          planeAnchor: planeARAnchor,
        );

        if (didAddNodeToAnchor == true) {
          allObjects.add(newNode);
        } else {
          sessionManager!.onError!("Object failed to attach anchor");
        }
      } else {
        sessionManager!.onError!("No plane found");
      }
    }
  }
}
