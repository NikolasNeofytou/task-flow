import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider localImageProviderFromPath(String path) {
  return FileImage(File(path));
}