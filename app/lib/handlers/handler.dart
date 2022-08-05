import 'dart:async';

import 'package:butterfly/bloc/document_bloc.dart';
import 'package:butterfly/cubits/settings.dart';
import 'package:butterfly/cubits/transform.dart';
import 'package:butterfly/dialogs/area/context.dart';
import 'package:butterfly/dialogs/elements/elements.dart';
import 'package:butterfly/models/element.dart';
import 'package:butterfly/models/painter.dart';
import 'package:butterfly/renderers/area.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../cubits/current_index.dart';
import '../dialogs/background/context.dart';
import '../dialogs/elements/label.dart';
import '../models/area.dart';
import '../models/document.dart';
import '../models/path_point.dart';
import '../models/property.dart';
import '../renderers/renderer.dart';
import '../widgets/context_menu.dart';

part 'area.dart';
part 'eraser.dart';
part 'hand.dart';
part 'label.dart';
part 'laser.dart';
part 'layer.dart';
part 'path_eraser.dart';
part 'pen.dart';
part 'shape.dart';

abstract class Handler<T> {
  final T data;

  const Handler(this.data);

  List<Renderer> createForegrounds(AppDocument document, [Area? currentArea]) =>
      [];

  List<Rect> createSelections(AppDocument document, [Area? currentArea]) => [];

  Future<bool> onRendererUpdated(
          AppDocument appDocument, Renderer old, Renderer updated) async =>
      false;

  void onTapUp(Size viewportSize, BuildContext context, TapUpDetails details) {}

  void onTapDown(
      Size viewportSize, BuildContext context, TapDownDetails details) {}

  void onSecondaryTapUp(
      Size viewportSize, BuildContext context, TapUpDetails details) {}

  void onSecondaryTapDown(
      Size viewportSize, BuildContext context, TapDownDetails details) {}

  void onPointerDown(
      Size viewportSize, BuildContext context, PointerDownEvent event) {}

  void onPointerMove(
      Size viewportSize, BuildContext context, PointerMoveEvent event) {}

  void onPointerUp(
      Size viewportSize, BuildContext context, PointerUpEvent event) {}

  void onPointerHover(
      Size viewportSize, BuildContext context, PointerHoverEvent event) {}

  void onLongPressEnd(
      Size viewportSize, BuildContext context, LongPressEndDetails details) {}

  int? getColor(DocumentBloc bloc) => null;

  T? setColor(DocumentBloc bloc, int color) => null;

  static Handler fromDocument(AppDocument document, int index) {
    final painter = document.painters[index];
    return Handler.fromPainter(painter);
  }

  static Handler fromPainter(Painter painter) {
    if (painter is PenPainter) {
      return PenHandler(painter);
    }
    if (painter is ShapePainter) {
      return ShapeHandler(painter);
    }
    if (painter is EraserPainter) {
      return EraserHandler(painter);
    }
    if (painter is LabelPainter) {
      return LabelHandler(painter);
    }
    if (painter is AreaPainter) {
      return AreaHandler(painter);
    }
    if (painter is PathEraserPainter) {
      return PathEraserHandler(painter);
    }
    if (painter is LayerPainter) {
      return LayerHandler(painter);
    }
    if (painter is LaserPainter) {
      return LaserHandler(painter);
    }
    return HandHandler(const HandProperty());
  }
}

typedef HitRequest = bool Function(Offset position, [double radius]);

class _SmallRenderer {
  final HitCalculator? hitCalculator;
  final PadElement element;

  _SmallRenderer(this.hitCalculator, this.element);
  _SmallRenderer.fromRenderer(Renderer renderer)
      : hitCalculator = renderer.hitCalculator,
        element = renderer.element;
}

class _RayCastParams {
  final List<String> invisibleLayers;
  final List<_SmallRenderer> renderers;
  final Offset globalPosition;
  final double radius;
  final double size;
  final bool includeEraser;

  const _RayCastParams(this.invisibleLayers, this.renderers,
      this.globalPosition, this.radius, this.size, this.includeEraser);
}

Future<Set<Renderer<PadElement>>> rayCast(
    BuildContext context, Offset localPosition, double radius,
    [bool includeEraser = false]) async {
  final bloc = context.read<DocumentBloc>();
  final transform = context.read<TransformCubit>().state;
  final state = bloc.state;
  if (state is! DocumentLoadSuccess) return {};
  final globalPosition = transform.localToGlobal(localPosition);
  final renderers = state.cameraViewport.visibleElements;
  return compute(
          _executeRayCast,
          _RayCastParams(
              state.invisibleLayers,
              renderers.map((e) => _SmallRenderer.fromRenderer(e)).toList(),
              globalPosition,
              radius,
              transform.size,
              includeEraser))
      .then((value) => value.map((e) => renderers[e]).toSet());
}

Set<int> _executeRayCast(_RayCastParams params) {
  return params.renderers
      .asMap()
      .entries
      .where((e) => !params.invisibleLayers.contains(e.value.element.layer))
      .where((e) =>
          e.value.hitCalculator?.hit(params.globalPosition, params.radius) ??
          false)
      .where((e) => params.includeEraser || e.value.element is! EraserElement)
      .map((e) => e.key)
      .toSet();
}
