let poseInFrameSchema = """
{
  "title": "foxglove.PoseInFrame",
  "description": "A timestamped pose for an object or reference frame in 3D space",
  "$comment": "Generated by https://github.com/foxglove/schemas",
  "type": "object",
  "properties": {
    "timestamp": {
      "type": "object",
      "title": "time",
      "properties": {
        "sec": {
          "type": "integer",
          "minimum": 0
        },
        "nsec": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      },
      "description": "Timestamp of pose"
    },
    "frame_id": {
      "type": "string",
      "description": "Frame of reference for pose position and orientation"
    },
    "pose": {
      "title": "foxglove.Pose",
      "description": "Pose in 3D space",
      "type": "object",
      "properties": {
        "position": {
          "title": "foxglove.Vector3",
          "description": "Point denoting position in 3D space",
          "type": "object",
          "properties": {
            "x": {
              "type": "number",
              "description": "x coordinate length"
            },
            "y": {
              "type": "number",
              "description": "y coordinate length"
            },
            "z": {
              "type": "number",
              "description": "z coordinate length"
            }
          }
        },
        "orientation": {
          "title": "foxglove.Quaternion",
          "description": "Quaternion denoting orientation in 3D space",
          "type": "object",
          "properties": {
            "x": {
              "type": "number",
              "description": "x value"
            },
            "y": {
              "type": "number",
              "description": "y value"
            },
            "z": {
              "type": "number",
              "description": "z value"
            },
            "w": {
              "type": "number",
              "description": "w value"
            }
          }
        }
      }
    }
  }
}
"""

let frameTransformsSchema = #"""
{
  "title": "foxglove.FrameTransforms",
  "description": "An array of FrameTransform messages",
  "$comment": "Generated by https://github.com/foxglove/schemas",
  "type": "object",
  "properties": {
    "transforms": {
      "type": "array",
      "items": {
        "title": "foxglove.FrameTransform",
        "description": "A transform between two reference frames in 3D space",
        "type": "object",
        "properties": {
          "timestamp": {
            "type": "object",
            "title": "time",
            "properties": {
              "sec": {
                "type": "integer",
                "minimum": 0
              },
              "nsec": {
                "type": "integer",
                "minimum": 0,
                "maximum": 999999999
              }
            },
            "description": "Timestamp of transform"
          },
          "parent_frame_id": {
            "type": "string",
            "description": "Name of the parent frame"
          },
          "child_frame_id": {
            "type": "string",
            "description": "Name of the child frame"
          },
          "translation": {
            "title": "foxglove.Vector3",
            "description": "Translation component of the transform",
            "type": "object",
            "properties": {
              "x": {
                "type": "number",
                "description": "x coordinate length"
              },
              "y": {
                "type": "number",
                "description": "y coordinate length"
              },
              "z": {
                "type": "number",
                "description": "z coordinate length"
              }
            }
          },
          "rotation": {
            "title": "foxglove.Quaternion",
            "description": "Rotation component of the transform",
            "type": "object",
            "properties": {
              "x": {
                "type": "number",
                "description": "x value"
              },
              "y": {
                "type": "number",
                "description": "y value"
              },
              "z": {
                "type": "number",
                "description": "z value"
              },
              "w": {
                "type": "number",
                "description": "w value"
              }
            }
          }
        }
      },
      "description": "Array of transforms"
    }
  }
}
"""#

let compressedImageSchema = #"""
{
  "title": "foxglove.CompressedImage",
  "description": "A compressed image",
  "$comment": "Generated by https://github.com/foxglove/schemas",
  "type": "object",
  "properties": {
    "timestamp": {
      "type": "object",
      "title": "time",
      "properties": {
        "sec": {
          "type": "integer",
          "minimum": 0
        },
        "nsec": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      },
      "description": "Timestamp of image"
    },
    "frame_id": {
      "type": "string",
      "description": "Frame of reference for the image. The origin of the frame is the optical center of the camera. +x points to the right in the image, +y points down, and +z points into the plane of the image."
    },
    "data": {
      "type": "string",
      "contentEncoding": "base64",
      "description": "Compressed image data"
    },
    "format": {
      "type": "string",
      "description": "Image format\n\nSupported values: `webp`, `jpeg`, `png`"
    }
  }
}
"""#
