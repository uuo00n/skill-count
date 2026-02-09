import 'dart:math' as math;
import 'package:flutter/material.dart';

// Enum to identify which group a block belongs to
enum BlockGroup { core, top, bottom, right, left, front, back }

// Data class to store the initial position and assigned group of a block
class BlockDef {
  final int x;
  final int y;
  final int z;
  final BlockGroup group;

  BlockDef(this.x, this.y, this.z, this.group);
}

class AnimatedCubeLogo extends StatefulWidget {
  final double size;
  final Duration duration;

  const AnimatedCubeLogo({
    super.key,
    this.size = 320.0,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AnimatedCubeLogo> createState() => _AnimatedCubeLogoState();
}

class _AnimatedCubeLogoState extends State<AnimatedCubeLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Store the randomized block configuration
  List<BlockDef> blocks = [];

  @override
  void initState() {
    super.initState();
    
    // Generate the randomized blocks
    _generateRandomizedBlocks();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  void _generateRandomizedBlocks() {
    blocks.clear();
    // Removed random generator to satisfy "deterministic" requirement
    // final random = math.Random();

    // Iterate through all 27 positions in a 3x3x3 grid
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        for (int z = -1; z <= 1; z++) {
          // 1. Core Block (0,0,0) - Fixed
          if (x == 0 && y == 0 && z == 0) {
            blocks.add(BlockDef(x, y, z, BlockGroup.core));
            continue;
          }

          // 2. Deterministic assignment for "scattered" look
          // We manually assign groups to ensure visible faces (Top, Right, Front)
          // are broken up nicely.
          BlockGroup assignedGroup;

          // Face Centers (Must belong to their face)
          if (x == 1 && y == 0 && z == 0) { assignedGroup = BlockGroup.right; }
          else if (x == -1 && y == 0 && z == 0) { assignedGroup = BlockGroup.left; }
          else if (x == 0 && y == 1 && z == 0) { assignedGroup = BlockGroup.front; }
          else if (x == 0 && y == -1 && z == 0) { assignedGroup = BlockGroup.back; }
          else if (x == 0 && y == 0 && z == 1) { assignedGroup = BlockGroup.top; }
          else if (x == 0 && y == 0 && z == -1) { assignedGroup = BlockGroup.bottom; }
          
          // Edges (12 edges) - Assign to split neighbors
          // Top Face Edges (z=1)
          else if (x == 1 && y == 0 && z == 1) { assignedGroup = BlockGroup.right; } // Top-Right Edge -> Right
          else if (x == -1 && y == 0 && z == 1) { assignedGroup = BlockGroup.top; } // Top-Left Edge -> Top
          else if (x == 0 && y == 1 && z == 1) { assignedGroup = BlockGroup.front; } // Top-Front Edge -> Front
          else if (x == 0 && y == -1 && z == 1) { assignedGroup = BlockGroup.top; } // Top-Back Edge -> Top
          
          // Middle Layer Edges (z=0)
          else if (x == 1 && y == 1 && z == 0) { assignedGroup = BlockGroup.right; } // Right-Front Edge -> Right
          else if (x == 1 && y == -1 && z == 0) { assignedGroup = BlockGroup.back; } // Right-Back Edge -> Back
          else if (x == -1 && y == 1 && z == 0) { assignedGroup = BlockGroup.left; } // Left-Front Edge -> Left
          else if (x == -1 && y == -1 && z == 0) { assignedGroup = BlockGroup.back; } // Left-Back Edge -> Back

          // Bottom Face Edges (z=-1)
          else if (x == 1 && y == 0 && z == -1) { assignedGroup = BlockGroup.right; }
          else if (x == -1 && y == 0 && z == -1) { assignedGroup = BlockGroup.left; }
          else if (x == 0 && y == 1 && z == -1) { assignedGroup = BlockGroup.bottom; }
          else if (x == 0 && y == -1 && z == -1) { assignedGroup = BlockGroup.back; }

          // Corners (8 corners) - Maximize scatter
          // Top Corners (z=1)
          else if (x == 1 && y == 1 && z == 1) { assignedGroup = BlockGroup.top; } // Top-Right-Front -> Top
          else if (x == -1 && y == 1 && z == 1) { assignedGroup = BlockGroup.front; } // Top-Left-Front -> Front
          else if (x == 1 && y == -1 && z == 1) { assignedGroup = BlockGroup.right; } // Top-Right-Back -> Right
          else if (x == -1 && y == -1 && z == 1) { assignedGroup = BlockGroup.left; } // Top-Left-Back -> Left

          // Bottom Corners (z=-1)
          else if (x == 1 && y == 1 && z == -1) { assignedGroup = BlockGroup.front; }
          else if (x == -1 && y == 1 && z == -1) { assignedGroup = BlockGroup.bottom; }
          else if (x == 1 && y == -1 && z == -1) { assignedGroup = BlockGroup.bottom; }
          else if (x == -1 && y == -1 && z == -1) { assignedGroup = BlockGroup.back; }
          
          // Fallback (Should not happen if all cases covered)
          else { assignedGroup = BlockGroup.top; }

          blocks.add(BlockDef(x, y, z, assignedGroup));
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.size * 0.2237), // Standard iOS icon curvature
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(widget.size * 0.25), // Add padding to show white background
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: IsometricPainter(_animation.value, blocks),
          );
        },
      ),
    );
  }
}

class IsometricPainter extends CustomPainter {
  final double progress; // 0.0 (Exploded) to 1.0 (Compact)
  final List<BlockDef> blocks; // Receive pre-generated blocks

  IsometricPainter(this.progress, this.blocks);

  // UI Theme Colors
  static const Color faceTop = Color(0xFF96D7D2);    // Top Face (Light Teal)
  static const Color faceLeft = Color(0xFF2D96AF);   // Left Face (Medium Teal/Blue)
  static const Color faceRight = Color(0xFF194B6E);  // Right Face (Dark Blue)

  // Core Colors (Orange for contrast)
  static const Color coreTop = Color(0xFFFFB74D);    // Light Orange
  static const Color coreLeft = Color(0xFFFF9800);   // Orange
  static const Color coreRight = Color(0xFFE65100);  // Dark Orange

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Dynamic cube size based on available canvas size
    // 3x3 grid needs roughly 6 units width/height in isometric view
    final double cubeSize = size.width / 6.0; 

    // List of all cubes to render
    List<Cube> renderCubes = [];

    // Animation parameter: expansion factor
    // progress 1.0 -> offset 0.0 (Compact)
    // progress 0.0 -> offset max (Exploded)
    double expansion = (1.0 - progress) * 1.9; // Increased spread

    // Create Cube instances based on BlockDef and current progress
    for (var block in blocks) {
      double dx = 0;
      double dy = 0;
      double dz = 0;
      
      Color cTop, cRight, cLeft;

      if (block.group == BlockGroup.core) {
        cTop = coreTop;
        cRight = coreRight;
        cLeft = coreLeft;
      } else {
        cTop = faceTop;
        cRight = faceRight;
        cLeft = faceLeft;

        // Calculate offset based on group
        switch (block.group) {
          case BlockGroup.top:
            dz = expansion;
            break;
          case BlockGroup.bottom:
            dz = -expansion;
            break;
          case BlockGroup.right:
            dx = expansion;
            break;
          case BlockGroup.left:
            dx = -expansion;
            break;
          case BlockGroup.front:
            dy = expansion;
            break;
          case BlockGroup.back:
            dy = -expansion;
            break;
          default:
            break;
        }
      }

      renderCubes.add(Cube(
        x: block.x + dx,
        y: block.y + dy,
        z: block.z + dz,
        top: cTop,
        right: cRight,
        left: cLeft,
      ));
    }

    // Sort cubes by depth (Painter's Algorithm)
    // In isometric view from (1,1,1), depth correlates with -(x+y+z)
    // We want to draw back-to-front, so we sort by (x+y+z) ascending
    renderCubes.sort((a, b) {
      double sumA = a.x + a.y + a.z;
      double sumB = b.x + b.y + b.z;
      return sumA.compareTo(sumB);
    });

    // Draw all cubes
    for (var cube in renderCubes) {
      _drawCube(canvas, center, cube, cubeSize);
    }
  }

  void _drawCube(Canvas canvas, Offset center, Cube cube, double cubeSize) {
    // Projection Math
    // x_screen = (x - y) * cos(30) * size
    // y_screen = (x + y) * sin(30) * size - z * size

    double cos30 = math.cos(math.pi / 6);
    double sin30 = math.sin(math.pi / 6);

    double toScreenX(double x, double y, double z) {
      return (x - y) * cos30 * cubeSize + center.dx;
    }

    double toScreenY(double x, double y, double z) {
      return (x + y) * sin30 * cubeSize - z * cubeSize + center.dy;
    }

    // Vertices of the cube
    // We only need to draw the 3 visible faces: Top, Right, Left
    
    // Base position
    double x = cube.x;
    double y = cube.y;
    double z = cube.z;

    Offset p(double dx, double dy, double dz) {
      return Offset(toScreenX(x + dx, y + dy, z + dz), toScreenY(x + dx, y + dy, z + dz));
    }

    // Top Face (z=1 plane)
    Path topPath = Path()
      ..moveTo(p(0, 0, 1).dx, p(0, 0, 1).dy)
      ..lineTo(p(1, 0, 1).dx, p(1, 0, 1).dy)
      ..lineTo(p(1, 1, 1).dx, p(1, 1, 1).dy)
      ..lineTo(p(0, 1, 1).dx, p(0, 1, 1).dy)
      ..close();
    canvas.drawPath(topPath, Paint()..color = cube.top);

    // Right Face (x=1 plane)
    Path rightPath = Path()
      ..moveTo(p(1, 0, 1).dx, p(1, 0, 1).dy)
      ..lineTo(p(1, 1, 1).dx, p(1, 1, 1).dy)
      ..lineTo(p(1, 1, 0).dx, p(1, 1, 0).dy)
      ..lineTo(p(1, 0, 0).dx, p(1, 0, 0).dy)
      ..close();
    canvas.drawPath(rightPath, Paint()..color = cube.right);

    // Left Face (y=1 plane)
    Path leftPath = Path()
      ..moveTo(p(0, 1, 1).dx, p(0, 1, 1).dy)
      ..lineTo(p(1, 1, 1).dx, p(1, 1, 1).dy)
      ..lineTo(p(1, 1, 0).dx, p(1, 1, 0).dy)
      ..lineTo(p(0, 1, 0).dx, p(0, 1, 0).dy)
      ..close();
    canvas.drawPath(leftPath, Paint()..color = cube.left);
  }

  @override
  bool shouldRepaint(covariant IsometricPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class Cube {
  final double x;
  final double y;
  final double z;
  final Color top;
  final Color right;
  final Color left;

  Cube({
    required this.x,
    required this.y,
    required this.z,
    required this.top,
    required this.right,
    required this.left,
  });
}
