import 'package:flutter/material.dart';

ImageProvider localImageProviderFromPath(String path) {
  return NetworkImage(path);
}